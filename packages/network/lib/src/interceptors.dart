import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'connectivity_service.dart';

/// Adds the current Supabase access token to every request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._getAccessToken);

  final String? Function() _getAccessToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['apikey'] ??= _apiKey;
    super.onRequest(options, handler);
  }

  static String? _apiKey;

  static void configureAnonKey(String key) => _apiKey = key;
}

/// Lightweight request/response logging for development builds.
class TraceInterceptor extends Interceptor {
  TraceInterceptor({this.enabled = false});

  final bool enabled;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      // ignore: avoid_print
      print('--> ${options.method} ${options.uri}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      // ignore: avoid_print
      print('<-- ${err.response?.statusCode} ${err.requestOptions.uri}');
    }
    super.onError(err, handler);
  }
}

/// Fails fast when the device is offline, before Dio attempts a request.
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._isOnline);

  final bool Function() _isOnline;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_isOnline()) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: const NoConnectionException(),
        ),
      );
      return;
    }
    super.onRequest(options, handler);
  }
}

/// Reads the server-provided permission set and exposes it through [onPermissions].
class PermissionsInterceptor extends Interceptor {
  PermissionsInterceptor(this.onPermissions);

  final void Function(List<String> permissions) onPermissions;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final header = response.headers.value('x-easyfleet-permissions');
    if (header != null && header.isNotEmpty) {
      onPermissions(header.split(',').map((e) => e.trim()).toList());
    }
    super.onResponse(response, handler);
  }
}

/// Signals that the user must change their temporary password.
class PasswordChangeInterceptor extends Interceptor {
  PasswordChangeInterceptor(this.onPasswordChangeRequired);

  final void Function() onPasswordChangeRequired;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 428 ||
        response.headers.value('x-password-change') == 'true') {
      onPasswordChangeRequired();
    }
    super.onResponse(response, handler);
  }
}

/// Propagates 403 responses to a callback so the app can show a forbidden screen.
class ForbiddenInterceptor extends Interceptor {
  ForbiddenInterceptor(this.onForbidden);

  final void Function() onForbidden;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 403) onForbidden();
    super.onError(err, handler);
  }
}

/// Supabase session accessor used by [AuthInterceptor].
String? currentAccessToken() {
  return Supabase.instance.client.auth.currentSession?.accessToken;
}
