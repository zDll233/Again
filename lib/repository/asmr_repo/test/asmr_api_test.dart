import 'package:again/repository/asmr_repo/asmr_api.dart';
import 'package:again/utils/log.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void printFormattedMap(Map<String, dynamic> map) {
  const JsonEncoder encoder = JsonEncoder.withIndent('  '); // 设置缩进为两个空格
  String prettyPrint = encoder.convert(map);
  if (kDebugMode) {
    print(prettyPrint);
  }
}

void main() {
  // final ASMRAPI asmrApi = ASMRAPI(
  //   name: 'moondasscry',
  //   password: 'lzd951413',
  // );

  late final ASMRAPI asmrApi;

  setUpAll(() async {
    Log.debug('set up', simplePrint: true);
    asmrApi = ASMRAPI(
      name: 'moondasscry',
      password: 'lzd951413',
    );

    await asmrApi.login();
  });

  group('ASMRAPI', () {
    test('get playlist', () async {
      final playlist = await asmrApi.getPlaylists(page: 1);
      printFormattedMap(playlist);
    });

    // getSearchResult
    test('get search results', () async {
      final searchResults = await asmrApi.getSearchResult(
        content: '柚木',
        params: {
          'page': 1,
          'pageSize': 12,
          'filterBy': 'all',
        },
      );
      printFormattedMap(searchResults);
    });

    // getWorkInfo
    test('get work info', () async {
      final workInfo = await asmrApi.getWorkInfo(rj: 'RJ422979');
      printFormattedMap(workInfo);
    });

    // getVoiceTracks
    test('get voice tracks', () async {
      final voiceTracks = await asmrApi.getVoiceTracks(rj: 'RJ422979');
      for (var voiceTrack in voiceTracks) {
        printFormattedMap(voiceTrack);
      }
    });
  });
}
