import 'dart:async';
import 'dart:io';
import 'package:again/controllers/controller.dart';
import 'package:again/controllers/database_controller.dart';
import 'package:again/controllers/voice_updater.dart';
import 'package:again/models/voice_work.dart';
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

            VoiceWork updatedVoiceWork =
                await c.db.getVkByPath(voiceWork.directoryPath!);
            if (buttonContext.mounted) {
              _showPopupMenu(buttonContext, updatedVoiceWork, offset, size);
            }
          },
        );
      },
    );
  }

  void _showPopupMenu(
      BuildContext context, VoiceWork vk, Offset offset, Size size) {
    if (vk.title == null) return;

    // 动态获取菜单项
    List<String> cvList = VoiceUpdater.getCvList(vk.title!);
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
            .where((cate) => cate != "All" && cate != vk.category)
            .map((cate) =>
                PopupMenuItem<String>(value: cate, child: Text(cate))),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(value: "delete", child: Text("移至回收站")),
      ],
    ).then((selectedValue) {
      if (selectedValue != null) {
        _onPopMenuSelected(selectedValue, vk);
      }
    });
  }

  void _onPopMenuSelected(String value, VoiceWork vk) {
    if (value == "delete") {
      _deleteSelectedVkDir(vk);
    } else if (c.ui.cvNames.contains(value)) {
      _selectCv(value);
    } else if (c.ui.categories.contains(value)) {
      _selectCategory(value);
    }
  }

  Future<void> _deleteSelectedVkDir(VoiceWork vk) async {
    final scriptPath = p.join("scripts", "recycle.ps1");
    if (!await File(scriptPath).exists()) {
      Log.error("Error deleting ${vk.title}. Cannot find $scriptPath");
      return;
    }

    try {
      String filePath = vk.directoryPath!;
      List<String> arguments = [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        scriptPath,
        filePath
      ];
      ProcessResult result = await Process.run('powershell', arguments);
      Log.info("Deleted ${vk.title}.\n"
          "exitcode:${result.exitCode}, stdout:${result.stdout}, stderr:${result.stderr}.");
      await Get.find<DatabaseController>().onUpdatePressed();
    } catch (e) {
      Log.error("Error deleting VoiceWork directory.\n$e");
    }
  }

  void _selectCv(String cvName) {
    final cvIndex = c.ui.cvNames.indexOf(cvName);
    c.ui.onCvSelected(cvIndex);
    c.ui.scrollToIndex(c.ui.cvScrollController, cvIndex);
  }

  Future<void> _selectCategory(String cate) async {
    VoiceWork vk = await Get.find<DatabaseController>()
        .getVkByPath(c.ui.selectedVkList[selectedIndex].directoryPath!);

    // 将路径中的 vk.category 替换为新的 cate
    String newDirectoryPath =
        vk.directoryPath!.replaceFirst(vk.category!, cate);

    Directory oldDirectory = Directory(vk.directoryPath!);

    try {
      await moveDirectory(oldDirectory, newDirectoryPath);
      await c.db.onUpdatePressed();
    } catch (e) {
      Log.error("Error moving ${vk.directoryPath} to $newDirectoryPath.\n$e.");
    }
  }
}
