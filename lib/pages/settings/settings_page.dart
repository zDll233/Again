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
  int _hoverTimeWeight = const UiSettings().hoverTimeWeight;
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
      _hoverTimeWeight = config['hoverTimeWeight'] == 700 ? 700 : 400;
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
      // 检查失败: 提示网络问题, 并询问是否打开 GitHub Release 页面兜底
      final open = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('检查更新失败'),
          content: const Text('无法获取最新版本信息, 请检查网络。\n'
              '是否打开 GitHub Release 页面查看最新版本?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('打开 Release 页面'),
            ),
          ],
        ),
      );
      if (open == true && mounted) {
        try {
          await openUrl(kReleasesUrl);
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('打开浏览器失败, 请手动访问 GitHub')),
          );
        }
      }
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
      _hoverTimeWeight = 400;
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
                                // 每个文字位置一行, 点击弹出编辑面板 (效果预览 + 颜色/字号/字重)
                                SettingsTextPositionTile(
                                  icon: Icons.format_list_bulleted,
                                  title: '列表文字',
                                  sample: '列表文字示例 音声作品 01',
                                  sampleStyle: _panelTextStyle(),
                                  onTap: () => _editTextPosition(
                                    icon: Icons.format_list_bulleted,
                                    title: '列表文字',
                                    sample: '列表文字示例 音声作品 01',
                                    fallback: scheme.onSurface,
                                    previewStyle: _panelTextStyle,
                                    sizeValue: () => _panelTextSize,
                                    onSizeChanged: (v) => _panelTextSize = v,
                                    sizeKey: 'panelTextSize',
                                    sizeDefault: 14,
                                    colorValue: () => _panelTextColor,
                                    onColorChanged: (v) => _panelTextColor = v,
                                    colorKey: 'panelTextColor',
                                    weightValue: () => _panelTextWeight,
                                    onWeightChanged: (v) => _panelTextWeight = v,
                                    weightKey: 'panelTextWeight',
                                    weightDefault: _defaults.panelTextWeight,
                                  ),
                                ),
                                SettingsTextPositionTile(
                                  icon: Icons.title,
                                  title: '面板标题',
                                  sample: '面板标题',
                                  sampleStyle: _panelTitleStyle(),
                                  onTap: () => _editTextPosition(
                                    icon: Icons.title,
                                    title: '面板标题',
                                    sample: '面板标题',
                                    fallback:
                                        scheme.onSurface.withValues(alpha: 0.75),
                                    previewStyle: _panelTitleStyle,
                                    sizeValue: () => _panelTitleSize,
                                    onSizeChanged: (v) => _panelTitleSize = v,
                                    sizeKey: 'panelTitleSize',
                                    sizeDefault: 14,
                                    colorValue: () => _panelTitleColor,
                                    onColorChanged: (v) => _panelTitleColor = v,
                                    colorKey: 'panelTitleColor',
                                    weightValue: () => _panelTitleWeight,
                                    onWeightChanged: (v) => _panelTitleWeight = v,
                                    weightKey: 'panelTitleWeight',
                                    weightDefault: _defaults.panelTitleWeight,
                                  ),
                                ),
                                SettingsTextPositionTile(
                                  icon: Icons.schedule,
                                  title: '播放器时间',
                                  sample: '00:35 / 04:20',
                                  sampleStyle: _progressTimeStyle(),
                                  onTap: () => _editTextPosition(
                                    icon: Icons.schedule,
                                    title: '播放器时间',
                                    sample: '00:35 / 04:20',
                                    fallback: scheme.onSurface,
                                    previewStyle: _progressTimeStyle,
                                    sizeValue: () => _progressTextSize,
                                    onSizeChanged: (v) => _progressTextSize = v,
                                    sizeKey: 'progressTextSize',
                                    sizeDefault: 16,
                                    colorValue: () => _progressTextColor,
                                    onColorChanged: (v) => _progressTextColor = v,
                                    colorKey: 'progressTextColor',
                                    weightValue: () => _progressTextWeight,
                                    onWeightChanged: (v) => _progressTextWeight = v,
                                    weightKey: 'progressTextWeight',
                                    weightDefault: _defaults.progressTextWeight,
                                  ),
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
                                SettingsTextPositionTile(
                                  icon: Icons.music_note,
                                  title: '音声标题',
                                  sample: '音声标题示例',
                                  sampleStyle: _lyricTitleStyle(),
                                  onTap: () => _editTextPosition(
                                    icon: Icons.music_note,
                                    title: '音声标题',
                                    sample: '音声标题示例',
                                    fallback: scheme.onSurface,
                                    previewStyle: _lyricTitleStyle,
                                    sizeValue: () => _lyricTitleSize,
                                    onSizeChanged: (v) => _lyricTitleSize = v,
                                    sizeKey: 'lyricTitleSize',
                                    sizeDefault: 28,
                                    colorValue: () => _lyricTitleColor,
                                    onColorChanged: (v) => _lyricTitleColor = v,
                                    colorKey: 'lyricTitleColor',
                                    weightValue: () => _lyricTitleWeight,
                                    onWeightChanged: (v) => _lyricTitleWeight = v,
                                    weightKey: 'lyricTitleWeight',
                                    weightDefault: _defaults.lyricTitleWeight,
                                  ),
                                ),
                                SettingsTextPositionTile(
                                  icon: Icons.graphic_eq,
                                  title: '歌词当前行',
                                  sample: '正在播放的歌词行示例',
                                  sampleStyle: _lyricCurrentStyle(),
                                  onTap: () => _editTextPosition(
                                    icon: Icons.graphic_eq,
                                    title: '歌词当前行',
                                    sample: '正在播放的歌词行示例',
                                    fallback: scheme.primary,
                                    previewStyle: _lyricCurrentStyle,
                                    sizeValue: () => _lyricCurrentSize,
                                    onSizeChanged: (v) => _lyricCurrentSize = v,
                                    sizeKey: 'lyricCurrentSize',
                                    sizeDefault: _defaults.lyricCurrentSize,
                                    colorValue: () => _lyricHighlightColor,
                                    onColorChanged: (v) => _lyricHighlightColor = v,
                                    colorKey: 'lyricHighlightColor',
                                    weightValue: () => _lyricCurrentWeight,
                                    onWeightChanged: (v) => _lyricCurrentWeight = v,
                                    weightKey: 'lyricCurrentWeight',
                                    weightDefault: _defaults.lyricCurrentWeight,
                                  ),
                                ),
                                SettingsTextPositionTile(
                                  icon: Icons.notes,
                                  title: '歌词其他行',
                                  sample: '其他歌词行示例',
                                  sampleStyle: _lyricOtherStyle(),
                                  onTap: () => _editTextPosition(
                                    icon: Icons.notes,
                                    title: '歌词其他行',
                                    sample: '其他歌词行示例',
                                    fallback:
                                        scheme.onSurface.withValues(alpha: 0.55),
                                    previewStyle: _lyricOtherStyle,
                                    sizeValue: () => _lyricSize,
                                    onSizeChanged: (v) => _lyricSize = v,
                                    sizeKey: 'lyricSize',
                                    sizeDefault: 18,
                                    colorValue: () => _lyricColor,
                                    onColorChanged: (v) => _lyricColor = v,
                                    colorKey: 'lyricColor',
                                    weightValue: () => _lyricWeight,
                                    onWeightChanged: (v) => _lyricWeight = v,
                                    weightKey: 'lyricWeight',
                                    weightDefault: _defaults.lyricWeight,
                                  ),
                                ),
                                // 歌词起始时间: 位置行, 示例文字用悬停样式渲染; 点击弹出面板 (开关/颜色/字号/字重)
                                SettingsTextPositionTile(
                                  icon: Icons.timer_outlined,
                                  title: '歌词起始时间',
                                  sample: '00:35',
                                  sampleStyle: TextStyle(
                                    fontSize: _hoverTimeSize,
                                    fontWeight:
                                        fontWeightFor(_hoverTimeWeight),
                                    color: _hoverTimeColor?.resolve(
                                          Colors.white.withValues(alpha: 0.45),
                                          _themeHueSource()) ??
                                        Colors.white.withValues(alpha: 0.45),
                                  ),
                                  onTap: () => _editHoverTime(),
                                ),
                                // 二级设置项: 歌词行间距 / 歌词对齐 (放歌词文字块最后)
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
                                    color:
                                        scheme.onSurface.withValues(alpha: 0.6),
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
                                        _resetToDefault(['lyricAlign'],
                                            () => _lyricAlign = 'left');
                                      }),
                                    ],
                                  ),
                                ),
                                // 封面歌词 (仅 Android): 开关 + 两个位置行, 示例文字与主歌词一致
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
                                  SettingsTextPositionTile(
                                    icon: Icons.album,
                                    title: '封面歌词当前行',
                                    sample: '正在播放的歌词行示例',
                                    sampleStyle: _coverCurrentStyle(),
                                    onTap: () => _editTextPosition(
                                      icon: Icons.album,
                                      title: '封面歌词当前行',
                                      sample: '正在播放的歌词行示例',
                                      fallback: scheme.primary,
                                      previewStyle: _coverCurrentStyle,
                                      sizeValue: () => _lyricPreviewCurrentSize,
                                      onSizeChanged: (v) =>
                                          _lyricPreviewCurrentSize = v,
                                      sizeKey: 'lyricPreviewCurrentSize',
                                      sizeDefault:
                                          _defaults.lyricPreviewCurrentSize,
                                      sizeMin: 10,
                                      sizeMax: 24,
                                      colorValue: () =>
                                          _lyricPreviewHighlightColor,
                                      onColorChanged: (v) =>
                                          _lyricPreviewHighlightColor = v,
                                      colorKey: 'lyricPreviewHighlightColor',
                                      weightValue: () =>
                                          _lyricPreviewCurrentWeight,
                                      onWeightChanged: (v) =>
                                          _lyricPreviewCurrentWeight = v,
                                      weightKey: 'lyricPreviewCurrentWeight',
                                      weightDefault:
                                          _defaults.lyricPreviewCurrentWeight,
                                    ),
                                  ),
                                  SettingsTextPositionTile(
                                    icon: Icons.album_outlined,
                                    title: '封面歌词其他行',
                                    sample: '其他歌词行示例',
                                    sampleStyle: _coverOtherStyle(),
                                    onTap: () => _editTextPosition(
                                      icon: Icons.album_outlined,
                                      title: '封面歌词其他行',
                                      sample: '其他歌词行示例',
                                      fallback: scheme.onSurface
                                          .withValues(alpha: 0.55),
                                      previewStyle: _coverOtherStyle,
                                      sizeValue: () => _lyricPreviewSize,
                                      onSizeChanged: (v) =>
                                          _lyricPreviewSize = v,
                                      sizeKey: 'lyricPreviewSize',
                                      sizeDefault: _defaults.lyricPreviewSize,
                                      sizeMin: 10,
                                      sizeMax: 24,
                                      colorValue: () => _lyricPreviewColor,
                                      onColorChanged: (v) =>
                                          _lyricPreviewColor = v,
                                      colorKey: 'lyricPreviewColor',
                                      weightValue: () => _lyricPreviewWeight,
                                      onWeightChanged: (v) =>
                                          _lyricPreviewWeight = v,
                                      weightKey: 'lyricPreviewWeight',
                                      weightDefault:
                                          _defaults.lyricPreviewWeight,
                                    ),
                                  ),
                                ],
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

  /// 文字设置分组 (不可折叠, 组内每个位置一行)。
  Widget _textGroup({
    required String title,
    required List<Widget> children,
  }) =>
      SettingsTextGroup(title: title, children: children);

  /// 各文字位置效果预览样式: 读取当前 字号/字重/颜色, 行内预览与编辑面板共用。
  TextStyle _panelTextStyle() => TextStyle(
        fontSize: _panelTextSize,
        fontWeight: fontWeightFor(_panelTextWeight),
        color: _panelTextColor?.resolve(
                Theme.of(context).colorScheme.onSurface, _themeHueSource()) ??
            Theme.of(context).colorScheme.onSurface,
      );

  TextStyle _panelTitleStyle() => TextStyle(
        fontSize: _panelTitleSize,
        fontWeight: fontWeightFor(_panelTitleWeight),
        color: _panelTitleColor?.resolve(
                Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75),
                _themeHueSource()) ??
            Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.75),
      );

  TextStyle _progressTimeStyle() => TextStyle(
        fontSize: _progressTextSize,
        fontWeight: fontWeightFor(_progressTextWeight),
        color: _progressTextColor?.resolve(
                Theme.of(context).colorScheme.onSurface, _themeHueSource()) ??
            Theme.of(context).colorScheme.onSurface,
      );

  TextStyle _lyricTitleStyle() => TextStyle(
        fontSize: _lyricTitleSize,
        fontWeight: fontWeightFor(_lyricTitleWeight),
        color: _lyricTitleColor?.resolve(
                Theme.of(context).colorScheme.onSurface, _themeHueSource()) ??
            Theme.of(context).colorScheme.onSurface,
      );

  TextStyle _lyricCurrentStyle() => TextStyle(
        fontSize: _lyricCurrentSize,
        fontWeight: fontWeightFor(_lyricCurrentWeight),
        color: _lyricHighlightColor?.resolve(
                Theme.of(context).colorScheme.primary, _themeHueSource()) ??
            Theme.of(context).colorScheme.primary,
      );

  TextStyle _lyricOtherStyle() => TextStyle(
        fontSize: _lyricSize,
        fontWeight: fontWeightFor(_lyricWeight),
        color: _lyricColor?.resolve(
                Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
                _themeHueSource()) ??
            Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.55),
      );

  TextStyle _coverCurrentStyle() => TextStyle(
        fontSize: _lyricPreviewCurrentSize,
        fontWeight: fontWeightFor(_lyricPreviewCurrentWeight),
        color: _lyricPreviewHighlightColor?.resolve(
                Theme.of(context).colorScheme.primary, _themeHueSource()) ??
            Theme.of(context).colorScheme.primary,
      );

  TextStyle _coverOtherStyle() => TextStyle(
        fontSize: _lyricPreviewSize,
        fontWeight: fontWeightFor(_lyricPreviewWeight),
        color: _lyricPreviewColor?.resolve(
                Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
                _themeHueSource()) ??
            Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.55),
      );

  /// 打开文字位置编辑面板: 效果预览 (实时) + 颜色/字号/字重 三项设置。
  /// 面板内改动直接写配置, 预览样式通过 [previewStyle] 读取当前状态实时更新。
  Future<void> _editTextPosition({
    required IconData icon,
    required String title,
    required String sample,
    required Color fallback,
    required TextStyle Function() previewStyle,
    // 字号
    required double Function() sizeValue,
    required ValueChanged<double> onSizeChanged,
    required String sizeKey,
    required double sizeDefault,
    double sizeMin = 10,
    double sizeMax = 30,
    bool sizeRefreshAppearance = false,
    // 颜色
    required ColorSetting? Function() colorValue,
    required ValueChanged<ColorSetting?> onColorChanged,
    required String colorKey,
    // 字重
    required int Function() weightValue,
    required ValueChanged<int> onWeightChanged,
    required String weightKey,
    required int weightDefault,
  }) async {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final dialogScheme = Theme.of(context).colorScheme;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setInner) {
          // 面板内任意修改后刷新, 让效果预览实时跟随
          void refresh() => setInner(() {});
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: dialogScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: SizedBox(
              width: isNarrow ? null : 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 效果预览: 按当前 字号/字重/颜色 渲染, 调整即时反馈
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: dialogScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sample,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: previewStyle(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _textColorTile('颜色', colorValue(), colorKey, fallback,
                      onColorChanged,
                      onRefresh: refresh),
                  _textSizeTile('字号', sizeValue(), sizeKey, sizeDefault,
                      onSizeChanged,
                      min: sizeMin,
                      max: sizeMax,
                      refreshAppearance: sizeRefreshAppearance,
                      onRefresh: refresh),
                  _textWeightTile('字重', weightValue(), weightKey,
                      weightDefault, onWeightChanged,
                      onRefresh: refresh),
                ],
              ),
            ),
            // 无操作按钮: 点击面板外关闭, 面板内改动即时生效并写盘
          );
        },
      ),
    );
  }

  /// 打开「歌词起始时间」面板: 开关 / 颜色 / 字号 / 字重。
  Future<void> _editHoverTime() async {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final dialogScheme = Theme.of(context).colorScheme;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setInner) {
          void refresh() => setInner(() {});
          return AlertDialog(
            title: const Text('歌词起始时间'),
            content: SizedBox(
              width: isNarrow ? null : 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 实例文字: 进度样式时间, 按当前 颜色/字号/字重 渲染的悬停时间效果
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: dialogScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '00:35',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _hoverTimeSize,
                        fontWeight: fontWeightFor(_hoverTimeWeight),
                        color: _hoverTimeColor?.resolve(
                              Colors.white.withValues(alpha: 0.45),
                              _themeHueSource(),
                            ) ??
                            Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.timer_outlined,
                      size: 22,
                      color: dialogScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    title: const Text('显示歌词起始时间'),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: isNarrow ? 8 : 16),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: _showHoverTime,
                          onChanged: (value) async {
                            setState(() => _showHoverTime = value);
                            await _save({'showHoverTime': value});
                            ref.invalidate(uiSettingsProvider);
                            refresh();
                          },
                        ),
                        _resetButton(() {
                          _resetToDefault(['showHoverTime'],
                              () => _showHoverTime = true);
                          refresh();
                        }),
                      ],
                    ),
                  ),
                  // 起始时间颜色/字号/字重: 子设置, 关闭时隐藏
                  if (_showHoverTime)
                    _textColorTile('颜色', _hoverTimeColor, 'hoverTimeColor',
                        Colors.white.withValues(alpha: 0.45),
                        (v) => _hoverTimeColor = v,
                        onRefresh: refresh),
                  if (_showHoverTime)
                    _textSizeTile('歌词起始时间字号', _hoverTimeSize,
                        'hoverTimeSize', 14, (v) {
                      _hoverTimeSize = v;
                    },
                        icon: Icons.timer_outlined,
                        min: 10,
                        max: 24,
                        refreshAppearance: true,
                        onRefresh: refresh),
                  if (_showHoverTime)
                    _textWeightTile('字重', _hoverTimeWeight,
                        'hoverTimeWeight', 400, (v) {
                      _hoverTimeWeight = v;
                    },
                        onRefresh: refresh, refreshAppearance: true),
                ],
              ),
            ),
            // 无操作按钮: 点击面板外关闭, 面板内改动即时生效并写盘
          );
        },
      ),
    );
  }

  /// 字体大小设置行: 名称 + 滑杆 + 当前值 + 恢复默认;
  /// [onRefresh] 用于编辑面板内修改后刷新效果预览。
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
    VoidCallback? onRefresh,
  }) {
    return SettingsTextSizeTile(
      label: label,
      value: value,
      defaultValue: defaultValue,
      icon: icon,
      min: min,
      max: max,
      onChanged: (v) {
        setState(() => onChanged(v));
        onRefresh?.call();
      },
      onChangedEnd: (v) async {
        // 拖动结束再写盘 + 刷新, 避免拖动过程频繁写配置
        await _save({key: v.round()});
        if (refreshAppearance) {
          ref.invalidate(uiSettingsProvider);
        } else {
          ref.invalidate(textSettingsProvider);
        }
        onRefresh?.call();
      },
      onReset: () {
        _resetToDefault([key], () => onChanged(defaultValue));
        onRefresh?.call();
      },
    );
  }

  /// 字体字重设置行: 常规/粗体 (400/700) + 恢复默认;
  /// [refreshAppearance] 改动后刷新 uiSettingsProvider (外观类渲染读取)。
  Widget _textWeightTile(
    String label,
    int value,
    String key,
    int defaultValue,
    ValueChanged<int> onChanged, {
    VoidCallback? onRefresh,
    bool refreshAppearance = false,
  }) {
    return SettingsTextWeightTile(
      label: label,
      value: value,
      defaultValue: defaultValue,
      onChanged: (v) {
        setState(() => onChanged(v));
        onRefresh?.call();
      },
      onChangedEnd: (v) async {
        await _save({key: v});
        if (refreshAppearance) {
          ref.invalidate(uiSettingsProvider);
        } else {
          ref.invalidate(textSettingsProvider);
        }
        onRefresh?.call();
      },
      onReset: () {
        _resetToDefault([key], () => onChanged(defaultValue));
        onRefresh?.call();
      },
    );
  }

  /// 字体颜色设置行: 色块 + 名称 + 恢复默认; 未设置时显示默认色并标注。
  Widget _textColorTile(
    String label,
    ColorSetting? setting,
    String baseKey,
    Color fallback,
    ValueChanged<ColorSetting?> onChanged, {
    VoidCallback? onRefresh,
  }) {
    final themeHueSource = _themeHueSource();
    return SettingsTextColorTile(
      label: label,
      setting: setting,
      fallback: fallback,
      themeHueColor: themeHueSource.toColor(),
      onChanged: (v) {
        setState(() => onChanged(v));
        onRefresh?.call();
      },
      onReset: () {
        _resetToDefault(ColorSetting.keys(baseKey), () => onChanged(null));
        onRefresh?.call();
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
        onRefresh?.call();
      },
    );
  }
}
