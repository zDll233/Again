import 'package:again/common/const.dart';
import 'package:again/pages/settings/components/color_picker_dialog.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_providers.dart';
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
  // 默认值统一取自 TextSettings()/常量, 避免散落硬编码
  static const _defaults = TextSettings();
  String _voiceWorkRoot = '';
  bool _closeToTray = true;
  bool _rememberWindowPos = false;
  bool _rememberWindowSize = true;
  String _windowEffect = WINDOW_EFFECT_ACRYLIC;
  Color _themeSeedColor = kDefaultThemeSeed;
  bool _searchEnabled = false;
  bool _coverTilt = true;
  bool _coverReflection = true;
  // 文字设置 (大小/颜色, 颜色 null=跟随默认)
  double _panelTextSize = _defaults.panelTextSize;
  double _panelTitleSize = _defaults.panelTitleSize;
  double _progressTextSize = _defaults.progressTextSize;
  double _lyricTitleSize = _defaults.lyricTitleSize;
  double _lyricSize = _defaults.lyricSize;
  ColorSetting? _panelTextColor;
  ColorSetting? _panelTitleColor;
  ColorSetting? _progressTextColor;
  ColorSetting? _lyricHighlightColor;
  ColorSetting? _lyricColor;
  ColorSetting? _lyricTitleColor;
  double _lyricLineGap = _defaults.lyricLineGap;
  String _lyricAlign = _defaults.lyricAlign;
  String _listDensity = _defaults.listDensity;
  double _lyricCurrentSize = _defaults.lyricCurrentSize;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// 主题色相来源: primary 无彩色时回退 seed (极端主题下 primary 可能退化)。
  HSVColor _themeHueSource() {
    final scheme = Theme.of(context).colorScheme;
    final primaryHsv = HSVColor.fromColor(scheme.primary);
    if (primaryHsv.saturation > 0.1) return primaryHsv;
    final seed = ref.read(coverSeedColorProvider).valueOrNull ??
        kDefaultThemeSeed;
    return HSVColor.fromColor(seed);
  }

  Future<void> _load() async {
    final config = await ref.read(configJsonProvider).read();
    final ts = TextSettings.fromConfig(config);
    setState(() {
      _voiceWorkRoot = config['voiceWorkRoot'] ?? '';
      _closeToTray = config['closeToTray'] != false;
      _rememberWindowPos = config['rememberWindowPos'] == true;
      _rememberWindowSize = config['rememberWindowSize'] != false;
      _windowEffect = resolveWindowEffect(config);
      _themeSeedColor = parseHexColor(resolveThemeSeedHex(config)) ??
          kDefaultThemeSeed;
      _searchEnabled = config['searchEnabled'] == true;
      _panelTextSize = ts.panelTextSize;
      _panelTitleSize = ts.panelTitleSize;
      _progressTextSize = ts.progressTextSize;
      _lyricTitleSize = ts.lyricTitleSize;
      _lyricSize = ts.lyricSize;
      _panelTextColor = ts.panelTextColor;
      _panelTitleColor = ts.panelTitleColor;
      _progressTextColor = ts.progressTextColor;
      _lyricHighlightColor = ts.lyricHighlightColor;
      _lyricColor = ts.lyricColor;
      _lyricTitleColor = ts.lyricTitleColor;
      _lyricLineGap = ts.lyricLineGap;
      _lyricAlign = ts.lyricAlign;
      _listDensity = ts.listDensity;
      _coverTilt = ts.coverTilt;
      _coverReflection = ts.coverReflection;
      _lyricCurrentSize = ts.lyricCurrentSize;
      _loading = false;
    });
  }

  Future<void> _save(Map<String, dynamic> updates) async {
    final config = await ref.read(configJsonProvider).read();
    await ref.read(configJsonProvider).write({...config, ...updates});
  }

  /// 写入时移除旧键 (liquidGlass / followCoverTheme 迁移)。
  Future<void> _saveMigrated(
      Map<String, dynamic> updates, List<String> removedKeys) async {
    final config = await ref.read(configJsonProvider).read();
    for (final key in removedKeys) {
      config.remove(key);
    }
    await ref.read(configJsonProvider).write({...config, ...updates});
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

  /// 恢复设置: 移除配置键回到默认值, 并刷新相关 provider。
  Future<void> _resetToDefault(
    List<String> keys,
    VoidCallback setDefault, {
    bool reapplyWindowEffect = false,
  }) async {
    setState(setDefault);
    // 先写完配置再刷新, 避免 provider 读到旧值
    await _saveMigrated({}, keys);
    ref.invalidate(coverSeedColorProvider);
    ref.invalidate(textSettingsProvider);
    ref.invalidate(windowEffectProvider);
    if (reapplyWindowEffect) {
      ref.read(uiServiceProvider).applyWindowEffect(_windowEffect);
    }
  }

  /// 重置所有设置: 二次确认后清空配置并恢复全部默认值。
  Future<void> _resetAllSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('重置所有设置'),
        content: const Text('将恢复所有设置的默认值, 包括主题色、文字样式、窗口效果等。确定继续吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: schemeError()),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('重置'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // 保留音声根目录 (重置应用设置, 不重置数据目录)
    final config = await ref.read(configJsonProvider).read();
    final voiceWorkRoot =
        config['voiceWorkRoot'] is String && (config['voiceWorkRoot'] as String).isNotEmpty
            ? config['voiceWorkRoot'] as String
            : _voiceWorkRoot;

    setState(() {
      // 全部恢复默认值 (统一取自 TextSettings()/常量)
      _closeToTray = true;
      _rememberWindowPos = false;
      _rememberWindowSize = true;
      _windowEffect = WINDOW_EFFECT_ACRYLIC;
      _themeSeedColor = kDefaultThemeSeed;
      _searchEnabled = false;
      _panelTextSize = _defaults.panelTextSize;
      _panelTitleSize = _defaults.panelTitleSize;
      _progressTextSize = _defaults.progressTextSize;
      _lyricTitleSize = _defaults.lyricTitleSize;
      _lyricSize = _defaults.lyricSize;
      _panelTextColor = null;
      _panelTitleColor = null;
      _progressTextColor = null;
      _lyricHighlightColor = null;
      _lyricColor = null;
      _lyricTitleColor = null;
      _lyricLineGap = _defaults.lyricLineGap;
      _lyricAlign = _defaults.lyricAlign;
      _listDensity = _defaults.listDensity;
      _coverTilt = true;
      _coverReflection = true;
      _lyricCurrentSize = _defaults.lyricCurrentSize;
    });
    // 清空其余配置 (所有键走默认), 刷新 provider 并重新应用窗口效果
    await ref.read(configJsonProvider).write({'voiceWorkRoot': voiceWorkRoot});
    ref.invalidate(coverSeedColorProvider);
    ref.invalidate(textSettingsProvider);
    ref.invalidate(windowEffectProvider);
    ref.invalidate(searchEnabledProvider);
    ref.read(uiServiceProvider).applyWindowEffect(_windowEffect);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已重置所有设置')),
      );
    }
  }

  Color schemeError() => Theme.of(context).colorScheme.error;

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
                                _voiceWorkRoot.isEmpty ? '未设置' : _voiceWorkRoot,
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
                              contentPadding: const EdgeInsets.only(
                                  left: 16, right: 16),
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
                            ListTile(
                              leading: const Icon(Icons.location_on_outlined),
                              title: const Text('记住窗口位置'),
                              contentPadding: const EdgeInsets.only(
                                  left: 16, right: 16),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: _rememberWindowPos,
                                    onChanged: (value) {
                                      setState(
                                          () => _rememberWindowPos = value);
                                      _save({'rememberWindowPos': value});
                                    },
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(
                                      ['rememberWindowPos'],
                                      () => _rememberWindowPos = false,
                                    );
                                  }),
                                ],
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.aspect_ratio),
                              title: const Text('记住窗口大小'),
                              contentPadding: const EdgeInsets.only(
                                  left: 16, right: 16),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: _rememberWindowSize,
                                    onChanged: (value) {
                                      setState(
                                          () => _rememberWindowSize = value);
                                      _save({'rememberWindowSize': value});
                                    },
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(
                                      ['rememberWindowSize'],
                                      () => _rememberWindowSize = true,
                                    );
                                  }),
                                ],
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
                              contentPadding: const EdgeInsets.only(
                                  left: 16, right: 16),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: _searchEnabled,
                                    onChanged: (value) async {
                                      setState(() => _searchEnabled = value);
                                      // 先写完配置再刷新, 避免读到旧值
                                      await _save({'searchEnabled': value});
                                      ref.invalidate(searchEnabledProvider);
                                    },
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(
                                      ['searchEnabled'],
                                      () => _searchEnabled = false,
                                    );
                                  }),
                                ],
                              ),
                            ),
                            ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.view_list,
                                size: 22,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              title: const Text('列表密度'),
                              contentPadding: const EdgeInsets.only(
                                  left: 16, right: 16),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 144,
                                    child: SegmentedButton<String>(
                                      segments: const [
                                        ButtonSegment(
                                          value: 'compact',
                                          label: Text('紧凑'),
                                        ),
                                        ButtonSegment(
                                          value: 'comfortable',
                                          label: Text('宽松'),
                                        ),
                                      ],
                                      selected: {_listDensity},
                                      showSelectedIcon: false,
                                      style: ButtonStyle(
                                        visualDensity:
                                            VisualDensity.compact,
                                      ),
                                      // 与"歌词对齐"行同宽, 保证重置按钮对齐
                                      onSelectionChanged:
                                          (selection) async {
                                        setState(() => _listDensity =
                                            selection.first);
                                        await _save(
                                            {'listDensity': _listDensity});
                                        ref.invalidate(
                                            textSettingsProvider);
                                      },
                                    ),
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(['listDensity'], () {
                                      _listDensity = 'comfortable';
                                    });
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                        _sectionTitle('外观'),
                        _card(
                          children: [
                            ListTile(
                              leading: _colorSwatch(_themeSeedColor),
                              title: const Text('主题色'),
                              contentPadding: const EdgeInsets.only(
                                  left: 16, right: 16),
                              trailing: _resetButton(() {
                                _resetToDefault(
                                  ['themeSeedColor'],
                                  () => _themeSeedColor = kDefaultThemeSeed,
                                );
                              }),
                              onTap: () async {
                                final result =
                                    await showDialog<ColorPickerResult>(
                                  context: context,
                                  builder: (context) => ColorPickerDialog(
                                    initial: _themeSeedColor,
                                    fallbackColor: kDefaultThemeSeed,
                                  ),
                                );
                                if (result == null) return;
                                final picked = result.color;
                                setState(() => _themeSeedColor = picked);
                                // 先写完配置再刷新主题, 避免 provider 读到旧值
                                await _saveMigrated(
                                  {'themeSeedColor': _toHex(picked)},
                                  ['themeColorMode', 'followCoverTheme'],
                                );
                                ref.invalidate(coverSeedColorProvider);
                              },
                            ),
                            ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.blur_on,
                                size: 22,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              title: const Text('窗口背景效果'),
                              contentPadding: const EdgeInsets.only(
                                  left: 16, right: 16),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 216,
                                    child: SegmentedButton<String>(
                                      segments: const [
                                        ButtonSegment(
                                          value: WINDOW_EFFECT_TRANSPARENT,
                                          label: Text('透明'),
                                        ),
                                        ButtonSegment(
                                          value: WINDOW_EFFECT_ACRYLIC,
                                          label: Text('亚克力'),
                                        ),
                                        ButtonSegment(
                                          value: WINDOW_EFFECT_OPAQUE,
                                          label: Text('不透明'),
                                        ),
                                      ],
                                      selected: {_windowEffect},
                                      showSelectedIcon: false,
                                      style: ButtonStyle(
                                        visualDensity:
                                            VisualDensity.compact,
                                      ),
                                      onSelectionChanged:
                                          (selection) async {
                                        final value = selection.first;
                                        setState(() => _windowEffect = value);
                                        // 迁移: 移除旧的 liquidGlass 布尔配置
                                        final config = await ref
                                            .read(configJsonProvider)
                                            .read();
                                        config.remove('liquidGlass');
                                        await ref
                                            .read(configJsonProvider)
                                            .write({
                                          ...config,
                                          'windowEffect': value
                                        });
                                        ref.invalidate(
                                            windowEffectProvider);
                                        ref.read(uiServiceProvider)
                                            .applyWindowEffect(value);
                                      },
                                    ),
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(
                                      ['windowEffect', 'liquidGlass'],
                                      () => _windowEffect =
                                          WINDOW_EFFECT_ACRYLIC,
                                      reapplyWindowEffect: true,
                                    );
                                  }),
                                ],
                              ),
                            ),
                            ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.threed_rotation,
                                size: 22,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              title: const Text('封面倾斜动画'),
                              contentPadding: const EdgeInsets.only(
                                  left: 16, right: 16),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: _coverTilt,
                                    onChanged: (value) async {
                                      setState(() => _coverTilt = value);
                                      await _save({'coverTilt': value});
                                      ref.invalidate(textSettingsProvider);
                                    },
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(['coverTilt'],
                                        () => _coverTilt = true);
                                  }),
                                ],
                              ),
                            ),
                            ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.filter_hdr,
                                size: 22,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              title: const Text('封面倒影'),
                              contentPadding: const EdgeInsets.only(
                                  left: 16, right: 16),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: _coverReflection,
                                    onChanged: (value) async {
                                      setState(() => _coverReflection = value);
                                      await _save(
                                          {'coverReflection': value});
                                      ref.invalidate(textSettingsProvider);
                                    },
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(['coverReflection'],
                                        () => _coverReflection = true);
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                        _card(
                          children: [
                            _textGroup(
                              title: '界面文字',
                              children: [
                                // 字体大小
                                _textSizeTile('列表文字', _panelTextSize,
                                    'panelTextSize', 14, (v) {
                                  _panelTextSize = v;
                                }),
                                _textSizeTile('面板标题', _panelTitleSize,
                                    'panelTitleSize', 14, (v) {
                                  _panelTitleSize = v;
                                }),
                                _textSizeTile('进度时间', _progressTextSize,
                                    'progressTextSize', 16, (v) {
                                  _progressTextSize = v;
                                }),
                                // 字体颜色
                                _textColorTile(
                                  '列表文字',
                                  _panelTextColor,
                                  'panelTextColor',
                                  Theme.of(context).colorScheme.onSurface,
                                  (v) => _panelTextColor = v,
                                ),
                                _textColorTile(
                                  '面板标题',
                                  _panelTitleColor,
                                  'panelTitleColor',
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.75),
                                  (v) => _panelTitleColor = v,
                                ),
                                _textColorTile(
                                  '进度时间',
                                  _progressTextColor,
                                  'progressTextColor',
                                  Theme.of(context).colorScheme.onSurface,
                                  (v) => _progressTextColor = v,
                                ),
                              ],
                            ),
                          ],
                        ),
                        _card(
                          children: [
                            _textGroup(
                              title: '歌词文字',
                              children: [
                                // 字体大小
                                _textSizeTile('歌词标题', _lyricTitleSize,
                                    'lyricTitleSize', 28, (v) {
                                  _lyricTitleSize = v;
                                }),
                                _textSizeTile('歌词', _lyricSize, 'lyricSize',
                                    18, (v) {
                                  _lyricSize = v;
                                }),
                                ListTile(
                                  dense: true,
                                  leading: Icon(
                                    Icons.text_increase,
                                    size: 22,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  title: const Text('当前行字号'),
                                  contentPadding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _lyricCurrentSize.toStringAsFixed(0),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: Slider(
                                          value: _lyricCurrentSize,
                                          min: 10,
                                          max: 30,
                                          onChanged: (v) => setState(() =>
                                              _lyricCurrentSize = v),
                                          onChangeEnd: (v) async {
                                            await _save({
                                              'lyricCurrentSize': v.round()
                                            });
                                            ref.invalidate(
                                                textSettingsProvider);
                                          },
                                        ),
                                      ),
                                      _resetButton(() {
                                        _resetToDefault(
                                            ['lyricCurrentSize'], () {
                                          _lyricCurrentSize = _lyricSize + 2;
                                        });
                                      }),
                                    ],
                                  ),
                                ),
                                _textSizeTile('歌词行间距', _lyricLineGap,
                                    'lyricLineGap', 25, (v) {
                                  _lyricLineGap = v;
                                },
                                    icon: Icons.format_line_spacing),
                                ListTile(
                                  dense: true,
                                  leading: Icon(
                                    Icons.format_align_center,
                                    size: 22,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  title: const Text('歌词对齐'),
                                  contentPadding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 144,
                                        child: SegmentedButton<String>(
                                          segments: const [
                                            ButtonSegment(
                                              value: 'center',
                                              label: Text('居中'),
                                            ),
                                            ButtonSegment(
                                              value: 'left',
                                              label: Text('靠左'),
                                            ),
                                          ],
                                          selected: {_lyricAlign},
                                          showSelectedIcon: false,
                                          style: ButtonStyle(
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                          onSelectionChanged:
                                              (selection) async {
                                            setState(() => _lyricAlign =
                                                selection.first);
                                            await _save(
                                                {'lyricAlign': _lyricAlign});
                                            ref.invalidate(
                                                textSettingsProvider);
                                          },
                                        ),
                                      ),
                                      _resetButton(() {
                                        _resetToDefault(
                                            ['lyricAlign'], () {
                                          _lyricAlign = 'left';
                                        });
                                      }),
                                    ],
                                  ),
                                ),
                                // 字体颜色
                                _textColorTile(
                                  '歌词高亮',
                                  _lyricHighlightColor,
                                  'lyricHighlightColor',
                                  Theme.of(context).colorScheme.primary,
                                  (v) => _lyricHighlightColor = v,
                                ),
                                _textColorTile(
                                  '歌词其他',
                                  _lyricColor,
                                  'lyricColor',
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.55),
                                  (v) => _lyricColor = v,
                                ),
                                _textColorTile(
                                  '歌词标题',
                                  _lyricTitleColor,
                                  'lyricTitleColor',
                                  Theme.of(context).colorScheme.onSurface,
                                  (v) => _lyricTitleColor = v,
                                ),
                              ],
                            ),
                          ],
                        ),
                        // 重置所有设置
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: _card(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.restart_alt,
                                  color: scheme.error,
                                ),
                                title: Text(
                                  '重置所有设置',
                                  style: TextStyle(color: scheme.error),
                                ),
                                contentPadding: const EdgeInsets.only(
                                    left: 16, right: 16),
                                onTap: _resetAllSettings,
                              ),
                            ],
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
    // 卡片间留间距, 独立模块视觉更清晰
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
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
      ),
    );
  }

  /// 可折叠的文字设置分组 (默认展开)。
  Widget _textGroup({
    required String title,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      title: Text(title),
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      // 子设置缩进, 层级更明显
      childrenPadding: const EdgeInsets.only(left: 20),
      // trailing 与重置按钮同构 (40px 容器 + 18px 图标), 右边缘精确对齐
      trailing: const SizedBox(
        width: 40,
        child: Icon(Icons.expand_more, size: 18),
      ),
      // 去掉 ExpansionTile 自带的分隔线/边框, 由外层卡片统一
      shape: const Border(),
      collapsedShape: const Border(),
      iconColor: Theme.of(context).colorScheme.onSurface,
      collapsedIconColor: Theme.of(context).colorScheme.onSurface,
      children: children,
    );
  }

  /// 字体大小设置行: 名称 + 滑杆 + 当前值 + 恢复默认。
  Widget _textSizeTile(
    String label,
    double value,
    String key,
    double defaultValue,
    ValueChanged<double> onChanged, {
    IconData icon = Icons.format_size,
  }) {
    return ListTile(
      dense: true,
      // leading 占位与颜色行/主题区一致, 文字起点对齐
      leading: Icon(
        icon,
        size: 22,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(label),
      contentPadding: const EdgeInsets.only(left: 16, right: 16),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              value.toStringAsFixed(0),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Slider(
              value: value,
              min: 10,
              max: 30,
              onChanged: (v) => setState(() => onChanged(v)),
              onChangeEnd: (v) async {
                // 拖动结束再写盘 + 刷新, 避免拖动过程频繁写配置
                await _save({key: v.round()});
                ref.invalidate(textSettingsProvider);
              },
            ),
          ),
          _resetButton(() {
            _resetToDefault([key], () => onChanged(defaultValue));
          }),
        ],
      ),
    );
  }

  /// 字体颜色设置行: 色块 + 名称 + 恢复默认; 未设置时显示默认色并标注。
  Widget _textColorTile(
    String label,
    ColorSetting? setting,
    String baseKey,
    Color fallback,
    ValueChanged<ColorSetting?> onChanged,
  ) {
    final themeHueSource = _themeHueSource();
    final displayColor = setting?.resolve(fallback, themeHueSource) ??
        fallback;
    return ListTile(
      dense: true,
      leading: _colorSwatch(displayColor),
      title: Text(label),
      contentPadding: const EdgeInsets.only(left: 16, right: 16),
      subtitle: setting == null ? const Text('跟随主题') : null,
      trailing: _resetButton(() {
        _resetToDefault(ColorSetting.keys(baseKey), () => onChanged(null));
      }),
      onTap: () async {
        final result = await showDialog<ColorPickerResult>(
          context: context,
          builder: (context) => ColorPickerDialog(
            initial: setting?.color ?? fallback,
            fallbackColor: fallback,
            themeHueColor: themeHueSource.toColor(),
            setting: setting,
          ),
        );
        if (result == null) return;
        final updated = result.themeHue
            ? ColorSetting(
                themeHue: true, sat: result.sat, val: result.val)
            : ColorSetting(color: result.color);
        setState(() => onChanged(updated));
        // 先写完整配置 (含清除旧的 Theme/Sat/Val 或 hex 键) 再刷新
        final config = await ref.read(configJsonProvider).read();
        for (final key in ColorSetting.keys(baseKey)) {
          config.remove(key);
        }
        await ref.read(configJsonProvider).write(
            {...config, ...updated.toConfig(baseKey)});
        ref.invalidate(textSettingsProvider);
      },
    );
  }
}
