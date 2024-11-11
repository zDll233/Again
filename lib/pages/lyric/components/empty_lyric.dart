import 'package:flutter/material.dart';

class EmptyLyric extends StatelessWidget {
  const EmptyLyric({super.key, bool haveLyric = false, bool readLyric = false})
      : _haveLyric = haveLyric,
        _readLyric = readLyric;

  final bool _haveLyric;
  final bool _readLyric;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _haveLyric
            ? _readLyric
                ? 'Cannot read lyric file'
                : 'Incorrect lyric format'
            : 'No lyric',
      ),
    );
  }
}
