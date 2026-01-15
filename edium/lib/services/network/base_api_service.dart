import 'dart:async';

import 'package:dio/dio.dart';
import 'package:edium/services/network/http_method.dart';

abstract class BaseApiService {
  final Dio _dio;

  BaseApiService(this._dio);

  Future<T> request<T>(
    String path, {
      required HttpMethod method,
      Map<String, dynamic>? req,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? query,
      Options? opt,
      required T Function(dynamic) parser,
    }) async {
      try {
        final options = _buildOptions(headers, opt);
        final response = await _dio.request(
          path, 
          data: req, 
          queryParameters: query, 
          options: options?.copyWith(method: method.name.toUpperCase()) 
            ?? Options(method: method.name.toUpperCase()));
        return parser(response.data);
      } catch (e) {
        throw e;
      }
    }

  Options? _buildOptions(Map<String, dynamic>? headers, Options? options) {
    if (headers == null && options == null) return null;
    final merged = options ?? Options();

    if (headers != null) {
      merged.headers = {
        ...?merged.headers,
        ...headers,
      };
    }
    return merged;
  }
}