import 'dart:async';
import 'dart:io';
import 'package:again/audio/audio_providers.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/repository/repository_providers.dart';
import 'package:again/services/voice_updater.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/utils/generate_script.dart';
import 'package:again/utils/log.dart';
import 'package:again/utils/move_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

class VkMenuBtn extends ConsumerStatefulWidget {
  final VoiceWork voiceWork;
  const VkMenuBtn({
    required this.voiceWork,
    super.key,
  });

  @override
  ConsumerState<VkMenuBtn> createState() => _VkMenuBtnState();
}

class _VkMenuBtnState extends ConsumerState<VkMenuBtn> {
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
    List<String> cvList = VoiceUpdater.getCvList(widget.voiceWork.title);
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
        ...ref
            .watch(categoryProvider)
            .values
            .where((cate) => cate != "All" && cate != widget.voiceWork.category)
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
    } else if (ref.read(cvProvider).values.contains(value)) {
      _selectCv(value);
    } else if (ref.read(categoryProvider).values.contains(value)) {
      _selectCategory(value);
    }
  }

  Future<void> _deleteSelectedVkDir() async {
    final scriptPath = p.join("scripts", "delete.ps1");
    if (!await File(scriptPath).exists()) {
      Log.error(
          'Error deleting "${widget.voiceWork.title}". Cannot find "$scriptPath"');
      await generateDeleteScript();
    }

    try {
      final voiceWorkState = ref.read(voiceWorkProvider);
      if (voiceWorkState.isPlaying &&
          voiceWorkState.playingItem == widget.voiceWork) {
        await ref.read(audioProvider.notifier).release();
      }

      List<String> arguments = [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        scriptPath,
        widget.voiceWork.directoryPath
      ];

      ProcessResult result = await Process.run('powershell', arguments);

      Log.info('Delete ${widget.voiceWork.title}.\n'
          'exitcode: ${result.exitCode}.\n'
          'stdout: ${result.stdout}\n'
          'stderr: ${result.stderr}');
      ref.read(repositoryProvider.notifier).onUpdatePressed();
    } catch (e) {
      Log.error('Error deleting VoiceWork directory.\n$e');
    }
  }

  void _selectCv(String cvName) {
    final cvIndex = ref.read(cvProvider).values.indexOf(cvName);
    ref.read(cvProvider.notifier).onSelected(cvIndex);
    final uiService = ref.read(uiServiceProvider);
    uiService.scrollToIndex(uiService.cvScrollController, cvIndex);
  }

  Future<void> _selectCategory(String cate) async {
    // 将路径中的 voiceWork.category 替换为新的 cate
    String newDirectoryPath = widget.voiceWork.directoryPath
        .replaceFirst(widget.voiceWork.category, cate);

    Directory oldDirectory = Directory(widget.voiceWork.directoryPath);

    try {
      final voiceWorkState = ref.read(voiceWorkProvider);
      if (voiceWorkState.isPlaying &&
          voiceWorkState.playingItem == widget.voiceWork) {
        await ref.read(audioProvider.notifier).release();
      }

      await moveDirectory(oldDirectory, newDirectoryPath);
      Log.info(
          'Move "${widget.voiceWork.title}" from "${widget.voiceWork.category}" to "$cate".');
      ref.read(repositoryProvider.notifier).onUpdatePressed();
      if (ref.read(uiServiceProvider).isFilterPlaying) {
        ref
            .read(voiceWorkProvider.notifier)
            .removeItemInPlayingValues(widget.voiceWork);
      }
    } catch (e) {
      Log.error(
          'Error moving "${oldDirectory.path}" to "$newDirectoryPath".\n$e.');
    }
  }
}
