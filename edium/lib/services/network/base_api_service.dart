import 'dart:async';

import 'package:dio/dio.dart';
import 'package:edium/services/network/api_exception.dart';
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
        options: options?.copyWith(method: method.name.toUpperCase()) ??
            Options(method: method.name.toUpperCase()),
      );
      return parser(response.data);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  ApiException _parseError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final description = data['description'] as String?;
      final errorCode = data['error'] as String?;
      final details = data['details'] as Map<String, dynamic>?;
      if (description != null && description.isNotEmpty) {
        return ApiException(description, code: errorCode, statusCode: statusCode, details: details);
      }
      if (errorCode != null) {
        return ApiException(_codeToMessage(errorCode), code: errorCode, statusCode: statusCode, details: details);
      }
    }

    return ApiException(_statusMessage(statusCode), statusCode: statusCode);
  }

  String _codeToMessage(String code) {
    switch (code) {
      case 'OTP_INVALID':
        return 'Неверный код';
      case 'OTP_NOT_FOUND_OR_EXPIRED':
        return 'Код не найден или истёк';
      case 'OTP_ALREADY_SENT':
        return 'Код уже отправлен, повторите через минуту';
      case 'OTP_ATTEMPTS_EXCEEDED':
        return 'Слишком много попыток. Запросите новый код';
      case 'PHONE_UNAVAILABLE':
        return 'Этот номер телефона недоступен';
      case 'MISSING_REG_TOKEN':
      case 'REGISTRATION_TOKEN_INVALID':
      case 'REGISTRATION_TOKEN_EXPIRED':
        return 'Сессия регистрации истекла. Начните заново';
      case 'REFRESH_TOKEN_INVALID':
      case 'REFRESH_TOKEN_EXPIRED':
        return 'Сессия истекла. Войдите снова';
      case 'VALIDATION_ERROR':
        return 'Некорректные данные запроса';
      case 'SESSION_COMPLETED':
        return 'Сессия уже завершена';
      default:
        return 'Ошибка: $code';
    }
  }

  String _statusMessage(int? status) {
    switch (status) {
      case 400:
        return 'Некорректный запрос';
      case 401:
        return 'Необходима авторизация';
      case 403:
        return 'Доступ запрещён';
      case 404:
        return 'Не найдено';
      case 429:
        return 'Слишком много запросов';
      case 500:
      case 502:
      case 503:
        return 'Ошибка сервера. Попробуйте позже';
      default:
        return 'Ошибка соединения';
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
