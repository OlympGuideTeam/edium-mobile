import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';

final getIt = GetIt.instance;

class DioHandler {
  final Dio dio;
  DioHandler._internal()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://edium.ru/',
            connectTimeout: const Duration(milliseconds: 10000),
            receiveTimeout: const Duration(milliseconds: 10000),
            sendTimeout: const Duration(milliseconds: 5000),
            contentType: 'application/json',
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // TODO: refresh token
            print("Запрос не авторизован");
          }
          return handler.next(error);
        },
      ),
    );
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
        enabled: kDebugMode,
      ),
    );
  }
  static void setup() {
    getIt.registerLazySingleton(() => DioHandler._internal());
  }
}
