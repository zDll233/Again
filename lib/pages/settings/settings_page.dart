import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/pages/settings/components/color_picker_dialog.dart';
import 'package:again/pages/settings/components/settings_widgets.dart';
import 'package:again/pages/window_title_bar/move_window.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/services/storage_permission.dart';
import 'package:again/services/ui/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/services/ui/presentation/voice_item/voice_item_state.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/theme/ui_settings.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/updater/update_checker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // 默认值统一取自 TextSettings()/常量, 避免散落硬编码
  static const _defaults = TextSettings();
  String _voiceWorkRoot = '';
  bool _closeToTray = kDefaultCloseToTray;
  bool _rememberWindowPos = kDefaultRememberWindowPos;
  bool _rememberWindowSize = kDefaultRememberWindowSize;
  String _windowEffect = WINDOW_EFFECT_ACRYLIC;
  Color _themeSeedColor = kDefaultThemeSeed;
  bool _searchEnabled = false;
  bool _searchFilter = true;
  bool _searchWorks = true;
  bool _searchTracks = true;
  bool _coverTilt = true;
  bool _coverReflection = true;
  bool _showSliderThumb = false;
  double _sliderThickness = 1;
  double _sliderThumbSize = 5;
  bool _showHoverTime = true;
  double _hoverTimeSize = 14;
  bool _showCoverLyric = true;
  // 文字设置 (大小/颜色, 颜色 null=跟随默认)
  double _panelTextSize = _defaults.panelTextSize;
  double _panelTitleSize = _defaults.panelTitleSize;
  double _progressTextSize = _defaults.progressTextSize;
  double _lyricTitleSize = _defaults.lyricTitleSize;
  double _lyricSize = _defaults.lyricSize;
  double _lyricPreviewSize = _defaults.lyricPreviewSize;
  double _lyricPreviewCurrentSize = _defaults.lyricPreviewCurrentSize;
  ColorSetting? _panelTextColor;
  ColorSetting? _panelTitleColor;
  ColorSetting? _progressTextColor;
  ColorSetting? _lyricHighlightColor;
  ColorSetting? _lyricColor;
  ColorSetting? _lyricPreviewHighlightColor;
  ColorSetting? _lyricPreviewColor;
  ColorSetting? _lyricTitleColor;
  ColorSetting? _hoverTimeColor; // 歌词起始时间 (悬停行时间) 颜色
  double _lyricLineGap = _defaults.lyricLineGap;
  String _lyricAlign = _defaults.lyricAlign;
  String _listDensity = const UiSettings().listDensity;
  double _lyricCurrentSize = _defaults.lyricCurrentSize;
  // 字重 (400/700, 默认=当前渲染效果)
  int _panelTextWeight = _defaults.panelTextWeight;
  int _panelTitleWeight = _defaults.panelTitleWeight;
  int _progressTextWeight = _defaults.progressTextWeight;
  int _lyricTitleWeight = _defaults.lyricTitleWeight;
  int _lyricWeight = _defaults.lyricWeight;
  int _lyricCurrentWeight = _defaults.lyricCurrentWeight;
  int _lyricPreviewWeight = _defaults.lyricPreviewWeight;
  int _lyricPreviewCurrentWeight = _defaults.lyricPreviewCurrentWeight;
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
    final seed =
        ref.read(coverSeedColorProvider).valueOrNull ?? kDefaultThemeSeed;
    return HSVColor.fromColor(seed);
  }

  Future<void> _load() async {
    final config = await ref.read(configJsonProvider).read();
    final ts = TextSettings.fromConfig(config);
    setState(() {
      _voiceWorkRoot = config['voiceWorkRoot'] ?? '';
      _closeToTray = config['closeToTray'] ?? kDefaultCloseToTray;
      _rememberWindowPos =
          config['rememberWindowPos'] ?? kDefaultRememberWindowPos;
      _rememberWindowSize =
          config['rememberWindowSize'] ?? kDefaultRememberWindowSize;
      _windowEffect = resolveWindowEffect(config);
      _themeSeedColor =
          parseHexColor(resolveThemeSeedHex(config)) ?? kDefaultThemeSeed;
      _searchEnabled = config['searchEnabled'] == true;
      _searchFilter = config['searchFilter'] != false;
      _searchWorks = config['searchWorks'] != false;
      _searchTracks = config['searchTracks'] != false;
      _panelTextSize = ts.panelTextSize;
      _panelTitleSize = ts.panelTitleSize;
      _progressTextSize = ts.progressTextSize;
      _lyricTitleSize = ts.lyricTitleSize;
      _lyricSize = ts.lyricSize;
      _lyricPreviewSize = ts.lyricPreviewSize;
      _lyricPreviewCurrentSize = ts.lyricPreviewCurrentSize;
      _panelTextColor = ts.panelTextColor;
      _panelTitleColor = ts.panelTitleColor;
      _progressTextColor = ts.progressTextColor;
      _lyricHighlightColor = ts.lyricHighlightColor;
      _lyricColor = ts.lyricColor;
      _lyricPreviewHighlightColor = ts.lyricPreviewHighlightColor;
      _lyricPreviewColor = ts.lyricPreviewColor;
      _lyricTitleColor = ts.lyricTitleColor;
      _lyricLineGap = ts.lyricLineGap;
      _lyricAlign = ts.lyricAlign;
      _listDensity = config['listDensity'] == 'compact'
          ? 'compact'
          : const UiSettings().listDensity;
      _coverTilt = config['coverTilt'] != false;
      _coverReflection = config['coverReflection'] != false;
      _showSliderThumb = config['showSliderThumb'] == true;
      final thickness = config['sliderThickness'];
      _sliderThickness = thickness is num ? thickness.toDouble() : 1;
      final thumbSize = config['sliderThumbSize'];
      _sliderThumbSize = thumbSize is num ? thumbSize.toDouble() : 5;
      _showHoverTime = config['showHoverTime'] != false;
      final hoverTimeSize = config['hoverTimeSize'];
      _hoverTimeSize = hoverTimeSize is num ? hoverTimeSize.toDouble() : 14;
      _showCoverLyric = config['showCoverLyric'] != false;
      _lyricCurrentSize = ts.lyricCurrentSize;
      _hoverTimeColor = ts.hoverTimeColor;
      _panelTextWeight = ts.panelTextWeight;
      _panelTitleWeight = ts.panelTitleWeight;
      _progressTextWeight = ts.progressTextWeight;
      _lyricTitleWeight = ts.lyricTitleWeight;
      _lyricWeight = ts.lyricWeight;
      _lyricCurrentWeight = ts.lyricCurrentWeight;
      _lyricPreviewWeight = ts.lyricPreviewWeight;
      _lyricPreviewCurrentWeight = ts.lyricPreviewCurrentWeight;
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
  Widget _resetButton(VoidCallback onPressed) =>
      SettingsResetButton(onPressed: onPressed);

  /// 面板搜索子开关行 (总开关的子项, 仅总开关开启时显示)。
  Widget _searchSubSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    List<String> resetKeys,
    VoidCallback setDefault,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    return ListTile(
      dense: true,
      leading: Icon(
        Icons.keyboard_arrow_right,
        size: 22,
        color: scheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding:
          EdgeInsets.only(left: isNarrow ? 28 : 40, right: isNarrow ? 8 : 16),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(value: value, onChanged: onChanged),
          _resetButton(() => _resetToDefault(resetKeys, setDefault)),
        ],
      ),
    );
  }

  /// 颜色圆点。
  Widget _colorSwatch(Color color) => SettingsColorSwatch(color: color);

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
    ref.invalidate(uiSettingsProvider);
    ref.invalidate(searchEnabledProvider);
    ref.invalidate(searchFilterEnabledProvider);
    ref.invalidate(searchWorksEnabledProvider);
    ref.invalidate(searchTracksEnabledProvider);
    if (reapplyWindowEffect) {
      ref.read(uiServiceProvider).applyWindowEffect(_windowEffect);
    }
  }

  /// 检查更新: 查询 GitHub 最新 Release, 有新版本时下载并更新。
  /// Windows: 下载 zip 覆盖式更新; Android: 下载 APK 唤起系统安装器。
  Future<void> _checkUpdate() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在检查更新…')),
    );
    final result = await checkForUpdate();
    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('检查更新失败, 请检查网络')),
      );
      return;
    }
    if (!result.hasUpdate || result.assetUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已是最新版本 ($kAppVersion)')),
      );
      return;
    }

    final download = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('发现新版本'),
        content: Text('最新版本: ${result.latestTag}\n'
            '当前版本: $kAppVersion\n\n是否下载并更新?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('下载更新'),
          ),
        ],
      ),
    );
    if (download != true || !mounted) return;

    // 下载进度对话框 (不可关闭)
    final progress = ValueNotifier<double>(0);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('正在下载更新…'),
        content: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (_, value, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: value),
              const SizedBox(height: 10),
              Text('${(value * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
      ),
    );
    final assetPath = await downloadUpdateAsset(
      result.assetUrl!,
      onProgress: (received, total) {
        progress.value = total > 0 ? received / total : 0;
      },
    );
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    if (assetPath == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('下载失败, 请稍后重试')),
      );
      return;
    }

    if (!mounted) return;
    if (Platform.isAndroid) {
      // Android: 唤起系统安装器, 用户确认后完成安装
      final install = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('更新已下载'),
          content: const Text('将打开系统安装器完成安装, 安装后覆盖当前版本。\n'
              '若无法安装, 请在系统设置中允许本应用"安装未知应用"。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('稍后'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('立即安装'),
            ),
          ],
        ),
      );
      if (install == true) {
        try {
          await applyUpdateAndroid(assetPath);
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('打开安装器失败, 请到设置开启"安装未知应用"')),
          );
        }
      }
      return;
    }

    final apply = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('更新已下载'),
        content: const Text('应用将关闭并自动完成更新, 确定现在更新吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('稍后'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
    if (apply == true) {
      await applyUpdate(assetPath);
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
    final voiceWorkRoot = config['voiceWorkRoot'] is String &&
            (config['voiceWorkRoot'] as String).isNotEmpty
        ? config['voiceWorkRoot'] as String
        : _voiceWorkRoot;

    setState(() {
      // 全部恢复默认值 (统一取自 TextSettings()/常量)
      _closeToTray = kDefaultCloseToTray;
      _rememberWindowPos = kDefaultRememberWindowPos;
      _rememberWindowSize = kDefaultRememberWindowSize;
      _windowEffect = WINDOW_EFFECT_ACRYLIC;
      _themeSeedColor = kDefaultThemeSeed;
      _searchEnabled = false;
      _searchFilter = true;
      _searchWorks = true;
      _searchTracks = true;
      _panelTextSize = _defaults.panelTextSize;
      _panelTitleSize = _defaults.panelTitleSize;
      _progressTextSize = _defaults.progressTextSize;
      _lyricTitleSize = _defaults.lyricTitleSize;
      _lyricSize = _defaults.lyricSize;
      _lyricPreviewSize = _defaults.lyricPreviewSize;
      _lyricPreviewCurrentSize = _defaults.lyricPreviewCurrentSize;
      _panelTextColor = null;
      _panelTitleColor = null;
      _progressTextColor = null;
      _lyricHighlightColor = null;
      _lyricColor = null;
      _lyricPreviewHighlightColor = null;
      _lyricPreviewColor = null;
      _lyricTitleColor = null;
      _lyricLineGap = _defaults.lyricLineGap;
      _lyricAlign = _defaults.lyricAlign;
      _listDensity = const UiSettings().listDensity;
      _coverTilt = true;
      _coverReflection = true;
      _showSliderThumb = false;
      _sliderThickness = 1;
      _sliderThumbSize = 5;
      _showHoverTime = true;
      _hoverTimeSize = 14;
      _showCoverLyric = true;
      _lyricCurrentSize = _defaults.lyricCurrentSize;
      _hoverTimeColor = null;
      _panelTextWeight = _defaults.panelTextWeight;
      _panelTitleWeight = _defaults.panelTitleWeight;
      _progressTextWeight = _defaults.progressTextWeight;
      _lyricTitleWeight = _defaults.lyricTitleWeight;
      _lyricWeight = _defaults.lyricWeight;
      _lyricCurrentWeight = _defaults.lyricCurrentWeight;
      _lyricPreviewWeight = _defaults.lyricPreviewWeight;
      _lyricPreviewCurrentWeight = _defaults.lyricPreviewCurrentWeight;
    });
    // 排序先恢复默认 (此时 config 尚未清空, 键会被写掉), 随后清空 config
    await ref
        .read(sortOrderProvider.notifier)
        .setSortOrder(SortOrder.byTitleAsc);
    ref.read(voiceItemProvider.notifier).setSortOrder(VoiceItemSort.titleAsc);
    // 清空其余配置 (所有键走默认), 刷新 provider 并重新应用窗口效果
    await ref.read(configJsonProvider).write({'voiceWorkRoot': voiceWorkRoot});
    ref.invalidate(coverSeedColorProvider);
    ref.invalidate(textSettingsProvider);
    ref.invalidate(windowEffectProvider);
    ref.invalidate(searchEnabledProvider);
    ref.invalidate(searchFilterEnabledProvider);
    ref.invalidate(searchWorksEnabledProvider);
    ref.invalidate(searchTracksEnabledProvider);
    ref.read(uiServiceProvider).applyWindowEffect(_windowEffect);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已重置所有设置')),
      );
    }
  }

  Color schemeError() => Theme.of(context).colorScheme.error;

  Future<void> _changeRootDir() async {
    // Android: 全文件访问权限是扫描外部存储的前提, 未授权时先请求并提示
    if (Platform.isAndroid && !await hasExternalStorageAccess()) {
      final granted = await requestExternalStorageAccess();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要"所有文件访问"权限才能选择音声根目录')),
        );
        return;
      }
    }
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
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
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
                    child: MoveWindow(
                      moveOnChildWidget: true,
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
                      padding: EdgeInsets.fromLTRB(
                          isNarrow ? 4 : 12, 12, isNarrow ? 4 : 12, 12),
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
                        // 窗口设置: Windows 专属
                        if (Platform.isWindows) ...[
                          _sectionTitle('窗口'),
                          _card(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.close_fullscreen),
                                title: const Text('关闭时最小化到托盘'),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: isNarrow ? 8 : 16),
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
                                        () =>
                                            _closeToTray = kDefaultCloseToTray,
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.location_on_outlined),
                                title: const Text('记住窗口位置'),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: isNarrow ? 8 : 16),
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
                                        () => _rememberWindowPos =
                                            kDefaultRememberWindowPos,
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.aspect_ratio),
                                title: const Text('记住窗口大小'),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: isNarrow ? 8 : 16),
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
                                        () => _rememberWindowSize =
                                            kDefaultRememberWindowSize,
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              // 窗口背景效果: 系统级 acrylic, 影响整体观感
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
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: isNarrow ? 8 : 16),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: isNarrow ? 168 : 216,
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
                                          visualDensity: VisualDensity.compact,
                                        ),
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
                                              .write({
                                            ...config,
                                            'windowEffect': value
                                          });
                                          ref.invalidate(windowEffectProvider);
                                          ref
                                              .read(uiServiceProvider)
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
                            ],
                          ),
                        ],
                        _sectionTitle('界面'),
                        _card(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.search),
                              title: const Text('列表搜索'),
                              subtitle: const Text('作品/分类/声优/音轨列表的搜索框'),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: isNarrow ? 8 : 16),
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
                            // 各面板搜索子开关: 总开关的子项, 总开关关闭时折叠
                            if (_searchEnabled) ...[
                              _searchSubSwitch(
                                '筛选面板',
                                '分类/声优',
                                _searchFilter,
                                (value) async {
                                  setState(() => _searchFilter = value);
                                  await _save({'searchFilter': value});
                                  ref.invalidate(searchFilterEnabledProvider);
                                },
                                ['searchFilter'],
                                () => _searchFilter = true,
                              ),
                              _searchSubSwitch(
                                '作品面板',
                                '作品列表',
                                _searchWorks,
                                (value) async {
                                  setState(() => _searchWorks = value);
                                  await _save({'searchWorks': value});
                                  ref.invalidate(searchWorksEnabledProvider);
                                },
                                ['searchWorks'],
                                () => _searchWorks = true,
                              ),
                              _searchSubSwitch(
                                '音轨面板',
                                '音轨列表',
                                _searchTracks,
                                (value) async {
                                  setState(() => _searchTracks = value);
                                  await _save({'searchTracks': value});
                                  ref.invalidate(searchTracksEnabledProvider);
                                },
                                ['searchTracks'],
                                () => _searchTracks = true,
                              ),
                            ],
                          ],
                        ),
                        _sectionTitle('外观'),
                        _card(
                          children: [
                            ListTile(
                              leading: _colorSwatch(_themeSeedColor),
                              title: const Text('主题色'),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: isNarrow ? 8 : 16),
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
                                Icons.view_list,
                                size: 22,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              title: const Text('列表密度'),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: isNarrow ? 8 : 16),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: isNarrow ? 120 : 144,
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
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      onSelectionChanged: (selection) async {
                                        setState(() =>
                                            _listDensity = selection.first);
                                        await _save(
                                            {'listDensity': _listDensity});
                                        ref.invalidate(uiSettingsProvider);
                                      },
                                    ),
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(['listDensity'], () {
                                      _listDensity =
                                          const UiSettings().listDensity;
                                    });
                                  }),
                                ],
                              ),
                            ),
                            // 封面倾斜/倒影: Windows 宽屏歌词页生效 (Android 已移除)
                            if (!Platform.isAndroid) ...[
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
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: isNarrow ? 8 : 16),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value: _coverTilt,
                                      onChanged: (value) async {
                                        setState(() => _coverTilt = value);
                                        await _save({'coverTilt': value});
                                        ref.invalidate(uiSettingsProvider);
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
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: isNarrow ? 8 : 16),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value: _coverReflection,
                                      onChanged: (value) async {
                                        setState(
                                            () => _coverReflection = value);
                                        await _save({'coverReflection': value});
                                        ref.invalidate(uiSettingsProvider);
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
                            ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.trip_origin,
                                size: 22,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              title: const Text('进度/音量条滑块圆点'),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: isNarrow ? 8 : 16),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: _showSliderThumb,
                                    onChanged: (value) async {
                                      setState(() => _showSliderThumb = value);
                                      await _save({'showSliderThumb': value});
                                      ref.invalidate(uiSettingsProvider);
                                    },
                                  ),
                                  _resetButton(() {
                                    _resetToDefault(['showSliderThumb'],
                                        () => _showSliderThumb = false);
                                  }),
                                ],
                              ),
                            ),
                            // 圆点大小: 滑块圆点的子设置, 关闭时折叠
                            if (_showSliderThumb)
                              _textSizeTile('滑块圆点大小', _sliderThumbSize,
                                  'sliderThumbSize', 5, (v) {
                                _sliderThumbSize = v;
                              },
                                  icon: Icons.circle_outlined,
                                  min: 4,
                                  max: 16,
                                  refreshAppearance: true),
                            _textSizeTile('进度/音量条粗细', _sliderThickness,
                                'sliderThickness', 1, (v) {
                              _sliderThickness = v;
                            },
                                icon: Icons.line_weight,
                                min: 1,
                                max: 12,
                                refreshAppearance: true),
                          ],
                        ),
                        _card(
                          children: [
                            _textGroup(
                              title: '界面文字',
                              children: [
                                // 每个文字位置一个可折叠分组: 颜色 / 字号 / 字重
                                SettingsTextPosition(title: '列表文字', children: [
                                  _textColorTile(
                                    '颜色',
                                    _panelTextColor,
                                    'panelTextColor',
                                    Theme.of(context).colorScheme.onSurface,
                                    (v) => _panelTextColor = v,
                                  ),
                                  _textSizeTile(
                                      '字号', _panelTextSize, 'panelTextSize', 14,
                                      (v) {
                                    _panelTextSize = v;
                                  }),
                                  _textWeightTile(
                                      '字重',
                                      _panelTextWeight,
                                      'panelTextWeight',
                                      _defaults.panelTextWeight, (v) {
                                    _panelTextWeight = v;
                                  }),
                                ]),
                                SettingsTextPosition(title: '面板标题', children: [
                                  _textColorTile(
                                    '颜色',
                                    _panelTitleColor,
                                    'panelTitleColor',
                                    Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.75),
                                    (v) => _panelTitleColor = v,
                                  ),
                                  _textSizeTile('字号', _panelTitleSize,
                                      'panelTitleSize', 14, (v) {
                                    _panelTitleSize = v;
                                  }),
                                  _textWeightTile(
                                      '字重',
                                      _panelTitleWeight,
                                      'panelTitleWeight',
                                      _defaults.panelTitleWeight, (v) {
                                    _panelTitleWeight = v;
                                  }),
                                ]),
                                SettingsTextPosition(title: '进度时间', children: [
                                  _textColorTile(
                                    '颜色',
                                    _progressTextColor,
                                    'progressTextColor',
                                    Theme.of(context).colorScheme.onSurface,
                                    (v) => _progressTextColor = v,
                                  ),
                                  _textSizeTile('字号', _progressTextSize,
                                      'progressTextSize', 16, (v) {
                                    _progressTextSize = v;
                                  }),
                                  _textWeightTile(
                                      '字重',
                                      _progressTextWeight,
                                      'progressTextWeight',
                                      _defaults.progressTextWeight, (v) {
                                    _progressTextWeight = v;
                                  }),
                                ]),
                              ],
                            ),
                          ],
                        ),
                        _card(
                          children: [
                            _textGroup(
                              title: '歌词文字',
                              children: [
                                // 每个文字位置一个可折叠分组: 颜色 / 字号 / 字重
                                SettingsTextPosition(title: '歌词标题', children: [
                                  _textColorTile(
                                    '颜色',
                                    _lyricTitleColor,
                                    'lyricTitleColor',
                                    Theme.of(context).colorScheme.onSurface,
                                    (v) => _lyricTitleColor = v,
                                  ),
                                  _textSizeTile('字号', _lyricTitleSize,
                                      'lyricTitleSize', 28, (v) {
                                    _lyricTitleSize = v;
                                  }),
                                  _textWeightTile(
                                      '字重',
                                      _lyricTitleWeight,
                                      'lyricTitleWeight',
                                      _defaults.lyricTitleWeight, (v) {
                                    _lyricTitleWeight = v;
                                  }),
                                ]),
                                SettingsTextPosition(title: '当前行', children: [
                                  _textColorTile(
                                    '颜色',
                                    _lyricHighlightColor,
                                    'lyricHighlightColor',
                                    Theme.of(context).colorScheme.primary,
                                    (v) => _lyricHighlightColor = v,
                                  ),
                                  _textSizeTile(
                                    '字号',
                                    _lyricCurrentSize,
                                    'lyricCurrentSize',
                                    _defaults.lyricCurrentSize,
                                    (v) => _lyricCurrentSize = v,
                                  ),
                                  _textWeightTile(
                                      '字重',
                                      _lyricCurrentWeight,
                                      'lyricCurrentWeight',
                                      _defaults.lyricCurrentWeight, (v) {
                                    _lyricCurrentWeight = v;
                                  }),
                                ]),
                                SettingsTextPosition(title: '其他行', children: [
                                  _textColorTile(
                                    '颜色',
                                    _lyricColor,
                                    'lyricColor',
                                    Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.55),
                                    (v) => _lyricColor = v,
                                  ),
                                  _textSizeTile(
                                      '字号', _lyricSize, 'lyricSize', 18, (v) {
                                    _lyricSize = v;
                                  }),
                                  _textWeightTile(
                                      '字重',
                                      _lyricWeight,
                                      'lyricWeight',
                                      _defaults.lyricWeight, (v) {
                                    _lyricWeight = v;
                                  }),
                                ]),
                                if (Platform.isAndroid) ...[
                                  ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.lyrics_outlined,
                                      size: 22,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                    title: const Text('封面歌词'),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: isNarrow ? 8 : 16),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Switch(
                                          value: _showCoverLyric,
                                          onChanged: (value) async {
                                            setState(
                                                () => _showCoverLyric = value);
                                            await _save(
                                                {'showCoverLyric': value});
                                            ref.invalidate(uiSettingsProvider);
                                          },
                                        ),
                                        _resetButton(() {
                                          _resetToDefault(['showCoverLyric'],
                                              () => _showCoverLyric = true);
                                        }),
                                      ],
                                    ),
                                  ),
                                  SettingsTextPosition(
                                      title: '封面歌词当前行',
                                      children: [
                                        _textColorTile(
                                          '颜色',
                                          _lyricPreviewHighlightColor,
                                          'lyricPreviewHighlightColor',
                                          Theme.of(context).colorScheme.primary,
                                          (v) =>
                                              _lyricPreviewHighlightColor = v,
                                        ),
                                        _textSizeTile(
                                            '字号',
                                            _lyricPreviewCurrentSize,
                                            'lyricPreviewCurrentSize',
                                            _defaults.lyricPreviewCurrentSize,
                                            (v) {
                                          _lyricPreviewCurrentSize = v;
                                        }, min: 10, max: 24),
                                        _textWeightTile(
                                            '字重',
                                            _lyricPreviewCurrentWeight,
                                            'lyricPreviewCurrentWeight',
                                            _defaults.lyricPreviewCurrentWeight,
                                            (v) {
                                          _lyricPreviewCurrentWeight = v;
                                        }),
                                      ]),
                                  SettingsTextPosition(
                                      title: '封面歌词其他行',
                                      children: [
                                        _textColorTile(
                                          '颜色',
                                          _lyricPreviewColor,
                                          'lyricPreviewColor',
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.55),
                                          (v) => _lyricPreviewColor = v,
                                        ),
                                        _textSizeTile(
                                            '字号',
                                            _lyricPreviewSize,
                                            'lyricPreviewSize',
                                            _defaults.lyricPreviewSize, (v) {
                                          _lyricPreviewSize = v;
                                        }, min: 10, max: 24),
                                        _textWeightTile(
                                            '字重',
                                            _lyricPreviewWeight,
                                            'lyricPreviewWeight',
                                            _defaults.lyricPreviewWeight, (v) {
                                          _lyricPreviewWeight = v;
                                        }),
                                      ]),
                                ],
                                // 非字体三件套的歌词布局选项
                                SettingsTextPosition(title: '歌词布局', children: [
                                  _textSizeTile('歌词行间距', _lyricLineGap,
                                      'lyricLineGap', 25, (v) {
                                    _lyricLineGap = v;
                                  }, icon: Icons.format_line_spacing),
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
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: isNarrow ? 8 : 16),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: isNarrow ? 120 : 144,
                                          child: SegmentedButton<String>(
                                            segments: const [
                                              ButtonSegment(
                                                value: 'left',
                                                label: Text('靠左'),
                                              ),
                                              ButtonSegment(
                                                value: 'center',
                                                label: Text('居中'),
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
                                          _resetToDefault(['lyricAlign'], () {
                                            _lyricAlign = 'left';
                                          });
                                        }),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.timer_outlined,
                                      size: 22,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                    title: const Text('歌词起始时间'),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: isNarrow ? 8 : 16),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Switch(
                                          value: _showHoverTime,
                                          onChanged: (value) async {
                                            setState(
                                                () => _showHoverTime = value);
                                            await _save(
                                                {'showHoverTime': value});
                                            ref.invalidate(uiSettingsProvider);
                                          },
                                        ),
                                        _resetButton(() {
                                          _resetToDefault(['showHoverTime'],
                                              () => _showHoverTime = true);
                                        }),
                                      ],
                                    ),
                                  ),
                                  // 歌词起始时间颜色/字号: 子设置, 关闭时折叠
                                  if (_showHoverTime)
                                    _textColorTile(
                                      '颜色',
                                      _hoverTimeColor,
                                      'hoverTimeColor',
                                      Colors.white.withValues(alpha: 0.45),
                                      (v) => _hoverTimeColor = v,
                                    ),
                                  if (_showHoverTime)
                                    _textSizeTile('歌词起始时间字号', _hoverTimeSize,
                                        'hoverTimeSize', 14, (v) {
                                      _hoverTimeSize = v;
                                    },
                                        icon: Icons.timer_outlined,
                                        min: 10,
                                        max: 24,
                                        refreshAppearance: true),
                                ]),
                              ],
                            ),
                          ],
                        ),
                        // 检查更新: Windows zip 覆盖更新, Android 下载 APK 安装
                        if (Platform.isWindows || Platform.isAndroid)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: _card(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.system_update_alt,
                                    color:
                                        scheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                  title: const Text('检查更新'),
                                  subtitle: Text('当前版本 $kAppVersion'),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: isNarrow ? 8 : 16),
                                  onTap: _checkUpdate,
                                ),
                              ],
                            ),
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
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: isNarrow ? 8 : 16),
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

  Widget _sectionTitle(String title) => SettingsSectionTitle(title: title);

  Widget _card({required List<Widget> children}) =>
      SettingsCard(children: children);

  /// 可折叠的文字设置分组 (默认展开)。
  Widget _textGroup({
    required String title,
    required List<Widget> children,
  }) =>
      SettingsTextGroup(title: title, children: children);

  /// 字体大小设置行: 名称 + 滑杆 + 当前值 + 恢复默认。
  Widget _textSizeTile(
    String label,
    double value,
    String key,
    double defaultValue,
    ValueChanged<double> onChanged, {
    IconData icon = Icons.format_size,
    double min = 10,
    double max = 30,
    bool refreshAppearance = false,
  }) {
    return SettingsTextSizeTile(
      label: label,
      value: value,
      defaultValue: defaultValue,
      icon: icon,
      min: min,
      max: max,
      onChanged: (v) => setState(() => onChanged(v)),
      onChangedEnd: (v) async {
        // 拖动结束再写盘 + 刷新, 避免拖动过程频繁写配置
        await _save({key: v.round()});
        if (refreshAppearance) {
          ref.invalidate(uiSettingsProvider);
        } else {
          ref.invalidate(textSettingsProvider);
        }
      },
      onReset: () {
        _resetToDefault([key], () => onChanged(defaultValue));
      },
    );
  }

  /// 字体字重设置行: 常规/粗体 (400/700) + 恢复默认。
  Widget _textWeightTile(
    String label,
    int value,
    String key,
    int defaultValue,
    ValueChanged<int> onChanged,
  ) {
    return SettingsTextWeightTile(
      label: label,
      value: value,
      defaultValue: defaultValue,
      onChanged: (v) => setState(() => onChanged(v)),
      onChangedEnd: (v) async {
        await _save({key: v});
        ref.invalidate(textSettingsProvider);
      },
      onReset: () {
        _resetToDefault([key], () => onChanged(defaultValue));
      },
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
    return SettingsTextColorTile(
      label: label,
      setting: setting,
      fallback: fallback,
      themeHueColor: themeHueSource.toColor(),
      onChanged: (v) => setState(() => onChanged(v)),
      onReset: () {
        _resetToDefault(ColorSetting.keys(baseKey), () => onChanged(null));
      },
      onSave: (updated) async {
        // 先写完整配置 (含清除旧的 Theme/Sat/Val 或 hex 键) 再刷新
        final config = await ref.read(configJsonProvider).read();
        for (final key in ColorSetting.keys(baseKey)) {
          config.remove(key);
        }
        await ref
            .read(configJsonProvider)
            .write({...config, ...updated.toConfig(baseKey)});
        ref.invalidate(textSettingsProvider);
      },
    );
  }
}
