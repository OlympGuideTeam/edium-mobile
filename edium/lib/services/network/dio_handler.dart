import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_refresh/dio_refresh.dart';
import 'package:edium/core/config/api_config.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
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
  Future<TokenStore>? _refreshInFlight;

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
          final refreshToken = tokenStore.refreshToken;
          if (refreshToken == null || refreshToken.isEmpty) {
            throw DioException(
              requestOptions: RequestOptions(
                path: DoormanEndpoints.authTokensRefresh.path,
              ),
              error: 'Missing refresh token',
            );
          }
          try {
            return await _refreshTokensSingleFlight(
              refreshToken: refreshToken,
            );
          } catch (e) {
            await _tokenStorage.deleteTokens();
            try {
              getIt<AuthBloc>().add(const SessionExpiredEvent());
            } catch (_) {}
            rethrow;
          }
        },

        shouldRefresh: (response) {
          if (response == null) return false;
          if (_isPublic(response.requestOptions.path)) return false;
          return response.statusCode == 401;
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
            debugPrint('[API ✗] type=${error.type} msg=${error.message}');
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
      await _refreshTokensSingleFlight(
        refreshToken: refreshToken,
      );
      return true;
    } catch (_) {
      await _tokenStorage.deleteTokens();
      return false;
    }
  }

  Future<TokenStore> _refreshTokensSingleFlight({
    required String refreshToken,
  }) {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final refreshFuture = _refreshTokensInternal(refreshToken: refreshToken);
    _refreshInFlight = refreshFuture;

    refreshFuture.whenComplete(() {
      if (identical(_refreshInFlight, refreshFuture)) {
        _refreshInFlight = null;
      }
    });

    return refreshFuture;
  }

  Future<TokenStore> _refreshTokensInternal({
    required String refreshToken,
  }) async {
    final response = await _postRefreshWithRetry(refreshToken: refreshToken);
    final newAccess = response.data['access_token'] as String;
    final newRefresh = response.data['refresh_token'] as String;
    await _tokenStorage.saveTokens(
      accessToken: newAccess,
      refreshToken: newRefresh,
    );
    final tokenStore = TokenStore(
      accessToken: newAccess,
      refreshToken: newRefresh,
    );
    _tokenManager.setToken(tokenStore);
    return tokenStore;
  }

  Future<Response<dynamic>> _postRefreshWithRetry({
    required String refreshToken,
  }) async {
    try {
      return await _postRefresh(refreshToken: refreshToken);
    } on DioException catch (e) {
      if (!_shouldRetryRefresh(e)) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return _postRefresh(refreshToken: refreshToken);
    }
  }

  Future<Response<dynamic>> _postRefresh({
    required String refreshToken,
  }) {
    return dio.post(
      DoormanEndpoints.authTokensRefresh.path,
      data: {'refresh_token': refreshToken},
    );
  }

  bool _shouldRetryRefresh(DioException e) {
    if (e.response != null) return false;
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.unknown;
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
