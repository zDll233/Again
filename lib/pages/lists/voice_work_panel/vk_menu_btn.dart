import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:again/pages/components/popup_menu_on_pressed.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/database/voice_updater.dart';
import 'package:again/models/voice_work.dart';

class VkMenuBtn extends ConsumerWidget {
  final VoiceWork voiceWork;
  static const Locale _zhCN = Locale('zh', 'CN');

  const VkMenuBtn({
    required this.voiceWork,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = <PopupMenuEntry<String>>[
      _buildCopySourceIdItem(),
      const PopupMenuDivider(),
      _buildCvListItem(context, ref),
      const PopupMenuDivider(),
      _buildCategoryMoveItem(context, ref),
      const PopupMenuDivider(),
      _buildDeleteItem(),
    ];

    return IconButton(
      onPressed: () => showPopupMenuOnPressed(
        context,
        items,
        (value) => _handleMenuAction(value, ref),
      ),
      icon: const Icon(Icons.more_vert),
    );
  }

  // 创建复制SourceId的菜单项
  PopupMenuItem<String> _buildCopySourceIdItem() {
    final sourceId = voiceWork.sourceId;
    return PopupMenuItem<String>(
      value: 'copySourceId',
      child: Text(sourceId.isEmpty ? '无sourceId' : sourceId, locale: _zhCN),
    );
  }

  // 创建声优列表菜单项
  PopupMenuItem<String> _buildCvListItem(BuildContext context, WidgetRef ref) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          const Icon(Icons.arrow_left_sharp),
          Expanded(child: Text('声优', locale: _zhCN)),
        ],
      ),
      onTap: () {
        showPopupMenuOnPressed(
          context,
          VoiceUpdater.getCvList(voiceWork.title)
              .map((cvName) =>
                  PopupMenuItem<String>(value: cvName, child: Text(cvName)))
              .toList(),
          (value) => ref.read(cvProvider.notifier).onSelectedByName(value),
        );
      },
    );
  }

  // 创建移动到分类菜单项
  PopupMenuItem<String> _buildCategoryMoveItem(
      BuildContext context, WidgetRef ref) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          const Icon(Icons.arrow_left_sharp),
          Expanded(child: Text('移动到分类', locale: _zhCN)),
        ],
      ),
      onTap: () {
        showPopupMenuOnPressed(
          context,
          ref
              .read(categoryProvider)
              .values
              .where((cate) => cate != 'All' && cate != voiceWork.category)
              .map((cate) =>
                  PopupMenuItem<String>(value: cate, child: Text(cate)))
              .toList(),
          (value) => ref
              .read(voiceWorkProvider.notifier)
              .changeCategory(voiceWork, value),
        );
      },
    );
  }

  // 创建删除菜单项
  PopupMenuItem<String> _buildDeleteItem() {
    return const PopupMenuItem<String>(
      value: 'delete',
      child: Text('移至回收站', locale: _zhCN),
    );
  }

  // 处理菜单项点击的逻辑
  void _handleMenuAction(String value, WidgetRef ref) {
    if (value == 'copySourceId') {
      if (VoiceUpdater.isSourceIdValid(voiceWork.sourceId)) {
        Clipboard.setData(ClipboardData(text: voiceWork.sourceId));
      }
    } else if (value == 'delete') {
      ref.read(voiceWorkProvider.notifier).deleteVoiceWork(voiceWork);
    }
  }
}
