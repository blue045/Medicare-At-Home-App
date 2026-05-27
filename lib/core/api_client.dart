import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'app_config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? token;

  Uri _uri(String path, [Map<String, String?> query = const {}]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final base = AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/$'), '');
    final uri = Uri.parse('$base$normalized');
    final cleanQuery = <String, String>{};
    query.forEach((key, value) {
      if (value != null && value.isNotEmpty) cleanQuery[key] = value;
    });
    return cleanQuery.isEmpty ? uri : uri.replace(queryParameters: cleanQuery);
  }

  Map<String, String> _headers({bool jsonBody = false}) {
    return {
      'accept': 'application/json',
      if (jsonBody) 'content-type': 'application/json',
      if (token != null && token!.isNotEmpty) 'authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String?> query = const {},
  }) async {
    return _send(() => _client.get(_uri(path, query), headers: _headers()));
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) {
    return _send(
      () => _client.post(
        _uri(path),
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> patchJson(String path, Map<String, dynamic> body) {
    return _send(
      () => _client.patch(
        _uri(path),
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> deleteJson(String path) {
    return _send(() => _client.delete(_uri(path), headers: _headers()));
  }

  Future<Map<String, dynamic>> _send(Future<http.Response> Function() run) async {
    http.Response response;
    try {
      response = await run().timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw ApiException('Request timed out. Check your internet connection.');
    } catch (_) {
      throw ApiException('Could not connect to the server. Check API_BASE_URL.');
    }

    Map<String, dynamic> data = {};
    if (response.body.trim().isNotEmpty) {
      try {
        final parsed = jsonDecode(response.body);
        if (parsed is Map<String, dynamic>) data = parsed;
      } catch (_) {
        data = {'error': response.body};
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        (data['error'] ?? data['message'] ?? 'Request failed').toString(),
        statusCode: response.statusCode,
      );
    }
    return data;
  }
}
