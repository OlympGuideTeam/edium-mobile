import 'package:dio/dio.dart';
import 'package:dio_refresh/dio_refresh.dart';
import 'package:edium/services/network/endpoints.dart';
import 'package:edium/services/token_storage/token_storage_interface.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';

final getIt = GetIt.instance;

class DioHandler {
  final Dio dio;
  final ITokenStorage _tokenStorage;
  final TokenManager _tokenManager;

  DioHandler._internal(this._tokenStorage)
      : _tokenManager = TokenManager.instance, 
      dio = Dio(
          BaseOptions(
            baseUrl: 'https://edium.ru/',
            connectTimeout: const Duration(milliseconds: 10000),
            receiveTimeout: const Duration(milliseconds: 10000),
            sendTimeout: const Duration(milliseconds: 5000),
            contentType: 'application/json',
          ),
        ) {
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _tokenStorage.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        }
      )
    );

    dio.interceptors.add(
      DioRefreshInterceptor(
        tokenManager: _tokenManager, 
        onRefresh: (dio, tokenStore) async {
          try {
            final response = await dio.post(
              DoormanEndpoints.authTokensRefresh.path, 
              data: {
                'refresh_token': tokenStore.refreshToken,
              }
            );

            final newAccessToken = response.data['access_token'] as String;
            final newRefreshToken = response.data['refresh_token'] as String;
            
            await _tokenStorage.saveTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);
            
            return TokenStore(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
          } catch (e) { // TODO: Выход на экран регистрации
            await _tokenStorage.deleteTokens();
            rethrow;
          }
        }, 

        shouldRefresh: (response) =>
          response?.statusCode == 401,

        authHeader: (tokenStore) {
          if (tokenStore.accessToken == null || 
              tokenStore.accessToken!.isEmpty) {
            return {};
          }
          return {
            'Authorization': 'Bearer ${tokenStore.accessToken}',
          };
        },
      )
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

  static Future<void> setup() async {
    final tokenStorage = getIt<ITokenStorage>();
    
    final accessToken = await tokenStorage.getAccessToken();
    final refreshToken = await tokenStorage.getRefreshToken();
    
    if (accessToken != null && refreshToken != null) {
      TokenManager.instance.setToken(
        TokenStore(
          accessToken: accessToken,
          refreshToken: refreshToken,
        ),
      );
    }
    
    getIt.registerSingleton<DioHandler>(
      DioHandler._internal(tokenStorage),
    );
  }
}
