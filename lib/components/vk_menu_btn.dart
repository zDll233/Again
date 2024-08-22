import 'dart:async';
import 'dart:io';
import 'package:again/controllers/controller.dart';
import 'package:again/controllers/database_controller.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/utils/move_file.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                await c.db.getVkByPath(voiceWork.directoryPath);
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
    // 动态获取菜单项
    List<String> cvList = vk.title.split('-')[0].split('&');
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
      ],
    ).then((selectedValue) {
      if (selectedValue != null) {
        _onPopMenuSelected(selectedValue);
      }
    });
  }

  void _onPopMenuSelected(String value) {
    if (c.ui.cvNames.contains(value)) {
      _selectCv(value);
    } else if (c.ui.categories.contains(value)) {
      _selectCategory(value);
    }
  }

  void _selectCv(String cvName) {
    final cvIndex = c.ui.cvNames.indexOf(cvName);
    c.ui.onCvSelected(cvIndex);
    c.ui.scrollToIndex(c.ui.cvScrollController, cvIndex);
  }

  Future<void> _selectCategory(String cate) async {
    VoiceWork vk = await Get.find<DatabaseController>()
        .getVkByPath(c.ui.selectedVkList[selectedIndex].directoryPath);

    // 将路径中的 vk.category 替换为新的 cate
    String newDirectoryPath =
        vk.directoryPath.replaceFirst(vk.category, cate);

    Directory oldDirectory = Directory(vk.directoryPath);

    try {
      await moveDirectory(oldDirectory, newDirectoryPath);
      c.db.onUpdatePressed();
    } catch (_) {}
  }
}
