import 'package:flutter/material.dart';

/// 面板头部: 默认显示文本, 点击后变为搜索框。
/// 失焦时恢复文本; 有搜索词时文本显示为主色并带清除入口。
class SearchableHeader extends StatefulWidget {
  final String title;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;

  /// 紧凑模式: 搜索框不显示前后缀图标, 输入区最大化(适合窄列)。
  final bool compact;

  const SearchableHeader({
    super.key,
    required this.title,
    required this.query,
    required this.onQueryChanged,
    required this.onClear,
    this.compact = false,
  });

  @override
  State<SearchableHeader> createState() => _SearchableHeaderState();
}

class _SearchableHeaderState extends State<SearchableHeader>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.text = widget.query;
  }

  @override
  void didUpdateWidget(covariant SearchableHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query && !_searching) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 窗口失焦或最小化时收起搜索框, 恢复为标题文本。
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _stopSearch();
    }
  }

  void _startSearch() {
    setState(() => _searching = true);
    _controller.text = widget.query;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _stopSearch() {
    setState(() => _searching = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasQuery = widget.query.isNotEmpty;

    return SizedBox(
      height: 40,
      child: _searching
          ? Center(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: widget.onQueryChanged,
                onSubmitted: (_) => _stopSearch(),
                onTapOutside: (_) => _stopSearch(),
                style: const TextStyle(fontSize: 13, height: 1.0),
                decoration: InputDecoration(
                  prefixIcon: widget.compact
                      ? null
                      : Icon(
                          Icons.search,
                          size: 16,
                          color: scheme.onSurface.withValues(alpha: 0.4),
                        ),
                  suffixIcon: widget.compact
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 15),
                          onPressed: () {
                            _controller.clear();
                            widget.onQueryChanged('');
                          },
                        ),
                  isDense: true,
                  filled: true,
                  fillColor: scheme.onSurface.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            )
          : InkWell(
              onTap: _startSearch,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasQuery
                                ? scheme.primary
                                : scheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      if (hasQuery)
                        InkWell(
                          onTap: widget.onClear,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.filter_alt,
                              size: 14,
                              color: scheme.primary,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.search,
                          size: 14,
                          color: scheme.onSurface.withValues(alpha: 0.3),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
