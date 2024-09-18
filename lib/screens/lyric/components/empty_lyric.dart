import 'package:flutter/material.dart';

class EmptyLyric extends StatelessWidget {
  const EmptyLyric({super.key, bool hasLyric = false, bool readLyric = false})
      : _hasLyric = hasLyric,
        _readLyric = readLyric;

  final bool _hasLyric;
  final bool _readLyric;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _hasLyric
            ? _readLyric
                ? 'Cannot read lyric file'
                : 'Incorrect lyric format'
            : 'No lyric',
      ),
    );
  }
}
