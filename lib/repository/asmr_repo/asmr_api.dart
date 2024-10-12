import 'dart:async';
import 'dart:io';

import 'package:again/utils/log.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

typedef RemoteSourceID = String; // Adjust this based on your actual type

class ASMRAPI {
  String _baseApiUrl = 'https://api.asmr-200.com/api/';

  final Map<String, dynamic> _headers = {
    "Referer": "https://www.asmr.one/",
    "Origin": "https://www.asmr.one",
    "Host": "api.asmr-200.com",
    "Connection": "keep-alive",
    "Sec-Fetch-Mode": "cors",
    "Sec-Fetch-Site": "cross-site",
    "Sec-Fetch-Dest": "empty",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/78.0.3904.108 Safari/537.36",
  };

  late Dio _dio;

  final String name;
  final String password;
  final String? proxy;

  ASMRAPI({
    required this.name,
    required this.password,
    this.proxy,
  }) {
    BaseOptions options = BaseOptions(
      baseUrl: _baseApiUrl,
      headers: _headers,
      connectTimeout: Duration(milliseconds: 5000),
      receiveTimeout: Duration(milliseconds: 3000),
    );

    _dio = Dio(options);

    // Set up proxy if provided
    if (proxy != null) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.findProxy = (uri) => "PROXY $proxy";
          return client;
        },
      );
    }
  }

  /// Sets the API channel by updating the base URL and host header.
  void setApiChannel(String apiChannel) {
    _baseApiUrl = 'https://$apiChannel/api/';
    _headers["Host"] = apiChannel;
    _dio.options.baseUrl = _baseApiUrl;
  }

  /// Logs in the user and updates the authorization header.
  Future<void> login() async {
    try {
      final response = await _dio.post(
        'auth/me',
        data: {"name": name, "password": password},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        _headers["Authorization"] = "Bearer $token";
        _dio.options.headers = _headers;
      } else {
        Log.error('Login failed with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      Log.error('Login failed: ${e.message}');
    } catch (e) {
      Log.error('Unexpected error during login: $e');
    }
  }

  /// Generic GET request with retry logic.
  Future<dynamic> get(String route, {Map<String, dynamic>? params}) async {
    while (true) {
      try {
        final response = await _dio.get(
          route,
          queryParameters: params,
        );
        return response.data;
      } on DioException catch (e) {
        Log.warning('GET request to $route failed: ${e.message}');
        await Future.delayed(Duration(seconds: 3));
      } catch (e) {
        Log.warning('Unexpected error during GET request to $route: $e');
        await Future.delayed(Duration(seconds: 3));
      }
    }
  }

  /// Generic POST request with retry logic.
  Future<dynamic> post(String route, {Map<String, dynamic>? data}) async {
    while (true) {
      try {
        final response = await _dio.post(
          route,
          data: data,
        );
        return response.data;
      } on DioException catch (e) {
        Log.warning('POST request to $route failed: ${e.message}');
        await Future.delayed(Duration(seconds: 3));
      } catch (e) {
        Log.warning('Unexpected error during POST request to $route: $e');
        await Future.delayed(Duration(seconds: 3));
      }
    }
  }

  /// Retrieves playlists with pagination and filtering.
  Future<Map<String, dynamic>> getPlaylists({
    required int page,
    int pageSize = 12,
    String filterBy = 'all',
  }) async {
    return await get('playlist/get-playlists', params: {
      "page": page,
      "pageSize": pageSize,
      "filterBy": filterBy,
    });
  }

  /// Creates a new playlist.
  Future<Map<String, dynamic>> createPlaylist({
    required String name,
    String? description,
    int privacy = 0,
  }) async {
    return await post('playlist/create-playlist', data: {
      "name": name,
      "description": description ?? "",
      "privacy": privacy,
      "locale": "zh-CN",
      "works": [],
    });
  }

  /// Adds works to a playlist.
  Future<Map<String, dynamic>> addWorksToPlaylist({
    required List<RemoteSourceID> sourceIds,
    required String plId,
  }) async {
    return await post('playlist/add-works-to-playlist', data: {
      "id": plId,
      "works": sourceIds,
    });
  }

  /// Deletes a playlist.
  Future<Map<String, dynamic>> deletePlaylist({
    required String plId,
  }) async {
    return await post('playlist/delete-playlist', data: {
      "id": plId,
    });
  }

  /// Searches for content.
  Future<Map<String, dynamic>> getSearchResult({
    required String content,
    required Map<String, dynamic> params,
  }) async {
    return await get('search/$content', params: params);
  }

  /// Lists works based on parameters.
  Future<Map<String, dynamic>> listWorks({
    required Map<String, dynamic> params,
  }) async {
    return await get('works', params: params);
  }

  /// Searches by tag name.
  Future<Map<String, dynamic>> searchByTag({
    required String tagName,
    required Map<String, dynamic> params,
  }) async {
    return await getSearchResult(
      content: "\$tag:$tagName\$",
      params: params,
    );
  }

  /// Searches by VA name.
  Future<Map<String, dynamic>> searchByVa({
    required String vaName,
    required Map<String, dynamic> params,
  }) async {
    return await getSearchResult(
      content: "\$va:$vaName\$",
      params: params,
    );
  }

  Future<Map<String, dynamic>> getWorkInfo({
    required RemoteSourceID rj,
  }) async {
    final id = rj.replaceAll(RegExp(r'[^0-9]'), '');
    return await get('work/$id');
  }

  Future<List<dynamic>> getVoiceTracks({
    required RemoteSourceID rj,
  }) async {
    final id = rj.replaceAll(RegExp(r'[^0-9]'), '');
    return await get('tracks/$id');
  }
}
