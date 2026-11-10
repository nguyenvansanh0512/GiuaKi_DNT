import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  const ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

class ApiService {
  final http.Client client;
  final String baseUrl;
  String? token;
  void Function()? onUnauthorized;
  ApiService({http.Client? client, String? baseUrl})
    : client = client ?? http.Client(),
      baseUrl = baseUrl ?? ApiConfig.baseUrl;

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
      final request = http.Request(method, uri);
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (body != null) request.body = jsonEncode(body);
      final response = await (() async {
        return http.Response.fromStream(await client.send(request));
      })().timeout(const Duration(seconds: 20));
      Map<String, dynamic> data = {};
      if (response.body.isNotEmpty) {
        try {
          data =
              jsonDecode(utf8.decode(response.bodyBytes))
                  as Map<String, dynamic>;
        } catch (_) {
          throw const ApiException(
            'API trả dữ liệu không hợp lệ. Kiểm tra địa chỉ backend.',
          );
        }
      }
      if (response.statusCode >= 400) {
        if (response.statusCode == 401 && path != '/api/auth/login') {
          onUnauthorized?.call();
        }
        throw ApiException(
          data['message'] as String? ?? 'Thao tác thất bại.',
          response.statusCode,
        );
      }
      return data;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'Kết nối quá thời gian. Kiểm tra backend và MongoDB Atlas.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Không kết nối được API. Kiểm tra backend, API_BASE_URL, mạng và CORS.',
      );
    } on FormatException {
      throw const ApiException(
        'Địa chỉ API hoặc dữ liệu phản hồi không hợp lệ.',
      );
    }
  }

  void dispose() => client.close();
}
