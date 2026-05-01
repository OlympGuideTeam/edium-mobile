import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_refresh/dio_refresh.dart';
import 'package:edium/core/config/api_config.dart';
import 'package:edium/services/network/endpoints.dart';
import 'package:edium/services/token_storage/token_storage_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class DioHandler {
  final Dio dio;
  final ITokenStorage _tokenStorage;
  final TokenManager _tokenManager;
  Timer? _refreshTimer;

  DioHandler._internal(this._tokenStorage)
      : _tokenManager = TokenManager.instance, 
      dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: const Duration(milliseconds: 10000),
            receiveTimeout: const Duration(milliseconds: 10000),
            sendTimeout: const Duration(milliseconds: 5000),
            contentType: 'application/json',
          ),
        ) {
    const _publicPaths = {
      DoormanEndpoints.otpSend,
      DoormanEndpoints.otpVerify,
      DoormanEndpoints.authRegister,
      DoormanEndpoints.authTokensRefresh,
    };

    bool _isPublic(String path) =>
        _publicPaths.any((e) => path.contains(e.path)) ||
        RegExp(r'caesar/v1/invitations/[^/]+$').hasMatch(path);

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!_isPublic(options.path)) {
            final accessToken = await _tokenStorage.getAccessToken();
            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
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

        shouldRefresh: (response) {
          if (response == null) return false;
          if (_isPublic(response.requestOptions.path)) return false;
          return response.statusCode == 401 || response.statusCode == 403;
        },

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

    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('[API →] ${options.method} ${options.uri}');
            if (options.data != null) debugPrint('[API →] body: ${options.data}');
            handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint('[API ←] ${response.statusCode} ${response.requestOptions.uri}');
            debugPrint('[API ←] data: ${response.data}');
            handler.next(response);
          },
          onError: (error, handler) {
            debugPrint('[API ✗] ${error.response?.statusCode} ${error.requestOptions.uri}');
            debugPrint('[API ✗] ${error.message}');
            if (error.response?.data != null) debugPrint('[API ✗] data: ${error.response?.data}');
            handler.next(error);
          },
        ),
      );
    }
  }

  Future<bool> refreshTokens() async {
    if (ApiConfig.useMock) return true;
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final response = await dio.post(
        DoormanEndpoints.authTokensRefresh.path,
        data: {'refresh_token': refreshToken},
      );
      final newAccess = response.data['access_token'] as String;
      final newRefresh = response.data['refresh_token'] as String;
      await _tokenStorage.saveTokens(accessToken: newAccess, refreshToken: newRefresh);
      _tokenManager.setToken(TokenStore(accessToken: newAccess, refreshToken: newRefresh));
      return true;
    } catch (_) {
      await _tokenStorage.deleteTokens();
      return false;
    }
  }

  void startProactiveRefresh() {
    if (ApiConfig.useMock) return;
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (_) async {
      await refreshTokens();
    });
  }

  void stopProactiveRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> syncTokenFromStorage() async {
    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (accessToken != null && refreshToken != null) {
      _tokenManager.setToken(TokenStore(accessToken: accessToken, refreshToken: refreshToken));
    }
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
