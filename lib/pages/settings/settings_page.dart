import 'package:again/common/const.dart';
import 'package:again/pages/settings/components/theme_color_dialog.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/cover_color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _voiceWorkRoot = '';
  bool _closeToTray = true;
  String _windowEffect = WINDOW_EFFECT_ACRYLIC;
  String _themeColorMode = THEME_COLOR_MODE_COVER;
  Color _themeSeedColor = kDefaultThemeSeed;
  String _textColorMode = TEXT_MODE_FOLLOW;
  Color _textColor = parseHexColor(kDefaultTextColorHex) ?? kDefaultThemeSeed;
  bool _searchEnabled = true;
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
      _windowEffect = resolveWindowEffect(config);
      _themeColorMode = resolveThemeColorMode(config);
      _themeSeedColor = parseHexColor(resolveThemeSeedHex(config)) ??
          kDefaultThemeSeed;
      _textColorMode = resolveTextColorMode(config);
      _textColor = parseHexColor(resolveTextColorHex(config)) ??
          (parseHexColor(kDefaultTextColorHex) ?? kDefaultThemeSeed);
      _searchEnabled = config['searchEnabled'] != false;
      _loading = false;
    });
  }

  Future<void> _save(Map<String, dynamic> updates) async {
    final config = await ref.read(configJsonProvider).read();
    await ref
        .read(configJsonProvider)
        .write({...config, ...updates});
  }

  /// 写入时移除旧键 (liquidGlass / followCoverTheme 迁移)。
  Future<void> _saveMigrated(
      Map<String, dynamic> updates, List<String> removedKeys) async {
    final config = await ref.read(configJsonProvider).read();
    for (final key in removedKeys) {
      config.remove(key);
    }
    await ref
        .read(configJsonProvider)
        .write({...config, ...updates});
  }

  /// 小号"恢复默认"按钮。
  Widget _resetButton(VoidCallback onPressed) {
    return IconButton(
      icon: const Icon(Icons.settings_backup_restore, size: 18),
      tooltip: '恢复默认',
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }

  /// 颜色圆点。
  Widget _colorSwatch(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  /// Color → #RRGGBB。
  String _toHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

  /// 弹出取色器。
  Future<void> _pickColor({
    required Color initial,
    required void Function(Color picked) onPicked,
  }) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) => ThemeColorDialog(initial: initial),
    );
    if (picked == null) return;
    onPicked(picked);
  }

  /// 恢复设置: 移除配置键回到默认值, 并刷新相关 provider。
  void _resetToDefault(
    List<String> keys,
    VoidCallback setDefault, {
    bool reapplyWindowEffect = false,
  }) {
    setState(setDefault);
    _saveMigrated({}, keys);
    ref.invalidate(coverSeedColorProvider);
    ref.invalidate(textColorProvider);
    ref.invalidate(windowEffectProvider);
    if (reapplyWindowEffect) {
      ref.read(uiServiceProvider).applyWindowEffect(_windowEffect);
    }
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
            // 顶部栏: 返回按钮留在拖动区外, 拖动区覆盖其余部分
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: '返回',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: DragToMoveArea(
                      child: SizedBox.expand(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '设置',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
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
                            ListTile(
                              leading: const Icon(Icons.close_fullscreen),
                              title: const Text('关闭时最小化到托盘'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: _closeToTray,
                                    onChanged: (value) {
                                      setState(() => _closeToTray = value);
                                      _save({'closeToTray': value});
                                    },
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(
                                      ['closeToTray'],
                                      () => _closeToTray = true,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                        _sectionTitle('主题'),
                        _card(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.palette_outlined),
                              title: const Text('跟随封面主色'),
                              subtitle: const Text('界面配色随正在播放作品的封面变化'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: _themeColorMode ==
                                        THEME_COLOR_MODE_COVER,
                                    onChanged: (value) {
                                      setState(() {
                                        _themeColorMode = value
                                            ? THEME_COLOR_MODE_COVER
                                            : THEME_COLOR_MODE_CUSTOM;
                                      });
                                      _saveMigrated(
                                        {'themeColorMode': _themeColorMode},
                                        ['followCoverTheme'],
                                      );
                                      ref.invalidate(coverSeedColorProvider);
                                    },
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(
                                      ['themeColorMode', 'followCoverTheme'],
                                      () => _themeColorMode =
                                          THEME_COLOR_MODE_COVER,
                                    );
                                  }),
                                ],
                              ),
                            ),
                            ListTile(
                              leading: _colorSwatch(_themeSeedColor),
                              title: const Text('主题色'),
                              subtitle: Text(
                                _themeColorMode == THEME_COLOR_MODE_CUSTOM
                                    ? '界面统一使用该颜色'
                                    : '没有封面时使用该颜色',
                              ),
                              trailing: _resetButton(() {
                                _resetToDefault(
                                  ['themeSeedColor'],
                                  () => _themeSeedColor = kDefaultThemeSeed,
                                );
                              }),
                              onTap: () => _pickColor(
                                initial: _themeSeedColor,
                                onPicked: (picked) {
                                  setState(() => _themeSeedColor = picked);
                                  _save({'themeSeedColor': _toHex(picked)});
                                  ref.invalidate(coverSeedColorProvider);
                                },
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.text_fields),
                              title: const Text('文字颜色独立设置'),
                              subtitle: const Text(
                                  '主文字、选中项文字改用固定颜色, 不受主题色影响'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value:
                                        _textColorMode == TEXT_MODE_CUSTOM,
                                    onChanged: (value) {
                                      setState(() {
                                        _textColorMode = value
                                            ? TEXT_MODE_CUSTOM
                                            : TEXT_MODE_FOLLOW;
                                      });
                                      _save(
                                          {'textColorMode': _textColorMode});
                                      ref.invalidate(textColorProvider);
                                    },
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(
                                      ['textColorMode', 'accentColorMode'],
                                      () =>
                                          _textColorMode = TEXT_MODE_FOLLOW,
                                    );
                                  }),
                                ],
                              ),
                            ),
                            if (_textColorMode == TEXT_MODE_CUSTOM)
                              ListTile(
                                leading: _colorSwatch(_textColor),
                                title: const Text('文字颜色'),
                                subtitle: const Text('主文字、歌词、选中项之外的文字使用该颜色'),
                                trailing: _resetButton(() {
                                  _resetToDefault(
                                    ['textColor', 'accentColor'],
                                    () => _textColor =
                                        parseHexColor(kDefaultTextColorHex) ??
                                            kDefaultThemeSeed,
                                  );
                                }),
                                onTap: () => _pickColor(
                                  initial: _textColor,
                                  onPicked: (picked) {
                                    setState(() => _textColor = picked);
                                    _save({'textColor': _toHex(picked)});
                                    ref.invalidate(textColorProvider);
                                  },
                                ),
                              ),
                            ListTile(
                              leading: const Icon(Icons.blur_on),
                              title: const Text('窗口背景效果'),
                              trailing: _resetButton(() {
                                _resetToDefault(
                                  ['windowEffect', 'liquidGlass'],
                                  () => _windowEffect = WINDOW_EFFECT_ACRYLIC,
                                  reapplyWindowEffect: true,
                                );
                              }),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: SizedBox(
                                width: double.infinity,
                                child: SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment(
                                      value: WINDOW_EFFECT_TRANSPARENT,
                                      label: Text('透明'),
                                    ),
                                    ButtonSegment(
                                      value: WINDOW_EFFECT_ACRYLIC,
                                      label: Text('毛玻璃'),
                                    ),
                                    ButtonSegment(
                                      value: WINDOW_EFFECT_OPAQUE,
                                      label: Text('不透明'),
                                    ),
                                  ],
                                  selected: {_windowEffect},
                                  showSelectedIcon: false,
                                  onSelectionChanged: (selection) async {
                                    final value = selection.first;
                                    setState(() => _windowEffect = value);
                                    // 迁移: 移除旧的 liquidGlass 布尔配置
                                    final config = await ref
                                        .read(configJsonProvider)
                                        .read();
                                    config.remove('liquidGlass');
                                    await ref
                                        .read(configJsonProvider)
                                        .write(
                                            {...config, 'windowEffect': value});
                                    ref.invalidate(windowEffectProvider);
                                    ref
                                        .read(uiServiceProvider)
                                        .applyWindowEffect(value);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        _sectionTitle('界面'),
                        _card(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.search),
                              title: const Text('列表搜索'),
                              subtitle: const Text('作品/分类/声优列表的搜索框'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: _searchEnabled,
                                    onChanged: (value) {
                                      setState(() => _searchEnabled = value);
                                      _save({'searchEnabled': value});
                                      ref.invalidate(searchEnabledProvider);
                                    },
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(
                                      ['searchEnabled'],
                                      () => _searchEnabled = true,
                                    );
                                  }),
                                ],
                              ),
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
          fontWeight: FontWeight.w700,
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
