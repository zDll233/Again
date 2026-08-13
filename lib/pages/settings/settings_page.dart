import 'package:again/common/const.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _voiceWorkRoot = '';
  bool _closeToTray = true;
  bool _followCoverTheme = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final config = await ref.read(configJsonProvider).read();
    setState(() {
      _voiceWorkRoot = config['voiceWorkRoot'] ?? '';
      _closeToTray = config['closeToTray'] != false;
      _followCoverTheme = config['followCoverTheme'] != false;
      _loading = false;
    });
  }

  Future<void> _save(Map<String, dynamic> updates) async {
    final config = await ref.read(configJsonProvider).read();
    await ref
        .read(configJsonProvider)
        .write({...config, ...updates});
  }

  Future<void> _changeRootDir() async {
    final selectedDirPath = await FilePicker.getDirectoryPath(
      dialogTitle: '请选择音声作品根目录',
      lockParentWindow: true,
    );
    if (selectedDirPath == null) return;
    setState(() => _voiceWorkRoot = selectedDirPath);
    // 保存配置并立即用新目录刷新数据库
    await ref.read(dbNotifierProvider).setRootDirectory(selectedDirPath);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface.withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部栏
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: '返回',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    '设置',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        _sectionTitle('音声'),
                        _card(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.folder_open),
                              title: const Text('音声作品根目录'),
                              subtitle: Text(
                                _voiceWorkRoot.isEmpty
                                    ? '未设置'
                                    : _voiceWorkRoot,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _changeRootDir,
                            ),
                          ],
                        ),
                        _sectionTitle('窗口'),
                        _card(
                          children: [
                            SwitchListTile(
                              secondary: const Icon(Icons.close_fullscreen),
                              title: const Text('关闭时最小化到托盘'),
                              value: _closeToTray,
                              onChanged: (value) {
                                setState(() => _closeToTray = value);
                                _save({'closeToTray': value});
                              },
                            ),
                          ],
                        ),
                        _sectionTitle('主题'),
                        _card(
                          children: [
                            SwitchListTile(
                              secondary: const Icon(Icons.palette_outlined),
                              title: const Text('跟随封面主色'),
                              subtitle: const Text('界面配色随选中作品封面变化'),
                              value: _followCoverTheme,
                              onChanged: (value) {
                                setState(() => _followCoverTheme = value);
                                _save({'followCoverTheme': value});
                                ref.invalidate(coverSeedColorProvider);
                              },
                            ),
                          ],
                        ),
                        _sectionTitle('界面(规划中)'),
                        _card(
                          children: const [
                            ListTile(
                              leading: Icon(Icons.construction_outlined),
                              title: Text('更多界面设置即将到来'),
                              subtitle: Text('播放器样式、列表密度、字体大小等'),
                              enabled: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Again v1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurface.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: scheme.primary,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: 56,
                  color: scheme.onSurface.withValues(alpha: 0.06),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}
