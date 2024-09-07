import 'dart:async';
import 'dart:io';
import 'package:again/controllers/controller.dart';
import 'package:again/controllers/voice_updater.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/utils/generate_script.dart';
import 'package:again/utils/log.dart';
import 'package:again/utils/move_file.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:path/path.dart' as p;

class VkMenuBtn extends StatelessWidget {
  late final VoiceWork voiceWork;
  late final int selectedIndex;
  final Controller c = Get.find();

  VkMenuBtn({super.key, required this.voiceWork, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext buttonContext) {
        return IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () async {
            final RenderBox button =
                buttonContext.findRenderObject() as RenderBox;
            final RenderBox overlay = Overlay.of(buttonContext)
                .context
                .findRenderObject() as RenderBox;

            // 获取按钮的位置和大小
            final Offset offset =
                button.localToGlobal(Offset.zero, ancestor: overlay);
            final Size size = button.size;

            if (buttonContext.mounted) {
              _showPopupMenu(buttonContext, offset, size);
            }
          },
        );
      },
    );
  }

  void _showPopupMenu(BuildContext context, Offset offset, Size size) {
    if (voiceWork.title == null) {
      Log.error('Failed to show popupmenu, selected vkTitle is null.');
      return;
    }

    // 动态获取菜单项
    List<String> cvList = VoiceUpdater.getCvList(voiceWork.title!);
    final screenSize = MediaQuery.of(context).size;
    double left = offset.dx + size.width;
    double top = offset.dy;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        left,
        top,
        screenSize.width - left,
        screenSize.height - top,
      ),
      items: <PopupMenuEntry<String>>[
        ...cvList.map((cvName) =>
            PopupMenuItem<String>(value: cvName, child: Text(cvName))),
        const PopupMenuDivider(),
        ...c.ui.categories
            .where((cate) => cate != "All" && cate != voiceWork.category)
            .map((cate) =>
                PopupMenuItem<String>(value: cate, child: Text(cate))),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(value: 'delete', child: Text('移至回收站')),
      ],
    ).then((selectedValue) {
      if (selectedValue != null) {
        _onPopMenuSelected(selectedValue);
      }
    });
  }

  void _onPopMenuSelected(String value) {
    if (value == "delete") {
      _deleteSelectedVkDir();
    } else if (c.ui.cvNames.contains(value)) {
      _selectCv(value);
    } else if (c.ui.categories.contains(value)) {
      _selectCategory(value);
    }
  }

  Future<void> _deleteSelectedVkDir() async {
    final scriptPath = p.join("scripts", "delete.ps1");
    if (!await File(scriptPath).exists()) {
      Log.error(
          'Error deleting "${voiceWork.title}". Cannot find "$scriptPath"');
      await generateDeleteScript();
    }

    try {
      String vkPath = voiceWork.directoryPath!;

      if (await c.ui.isCurrentVkPlaying(vkPath)) {
        await c.audio.release();
      }

      List<String> arguments = [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        scriptPath,
        vkPath
      ];

      ProcessResult result = await Process.run('powershell', arguments);

      Log.info('Delete ${voiceWork.title}.\n'
          'exitcode: ${result.exitCode}.\n'
          'stdout: ${result.stdout}\n'
          'stderr: ${result.stderr}');
      c.db.onUpdatePressed();
    } catch (e) {
      Log.error('Error deleting VoiceWork directory.\n$e');
    }
  }

  void _selectCv(String cvName) {
    final cvIndex = c.ui.cvNames.indexOf(cvName);
    c.ui.onCvSelected(cvIndex);
    c.ui.scrollToIndex(c.ui.cvScrollController, cvIndex);
  }

  Future<void> _selectCategory(String cate) async {
    VoiceWork voiceWork = await c.db
        .getVkByPath(c.ui.selectedVkList[selectedIndex].directoryPath!);

    // 将路径中的 voiceWork.category 替换为新的 cate
    String newDirectoryPath =
        voiceWork.directoryPath!.replaceFirst(voiceWork.category!, cate);

    Directory oldDirectory = Directory(voiceWork.directoryPath!);

    try {
      if (await c.ui.isCurrentVkPlaying(oldDirectory.path)) {
        await c.audio.release();
      }

      await moveDirectory(oldDirectory, newDirectoryPath);
      Log.info(
          'Move "${voiceWork.title}" from "${voiceWork.category}" to "$cate".');
      await c.db.onUpdatePressed();
    } catch (e) {
      Log.error(
          'Error moving "${oldDirectory.path}" to "$newDirectoryPath".\n$e.');
    }
  }
}
