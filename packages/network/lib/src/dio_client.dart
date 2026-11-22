import 'package:dio/dio.dart';
import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_service.dart';
import 'interceptors.dart';

/// Creates a Dio client configured for the EasyFleet Supabase project.
Dio createApiClient({
  required EnvironmentConfig environment,
  required bool Function() isOnline,
  bool enableTracing = false,
  void Function(List<String>)? onPermissions,
  void Function()? onForbidden,
  void Function()? onPasswordChangeRequired,
}) {
  AuthInterceptor.configureAnonKey(environment.supabaseAnonKey);

  final dio = Dio(
    BaseOptions(
      baseUrl: environment.supabaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    ConnectivityInterceptor(isOnline),
    AuthInterceptor(currentAccessToken),
    TraceInterceptor(enabled: enableTracing),
    PermissionsInterceptor(onPermissions ?? (_) {}),
    PasswordChangeInterceptor(onPasswordChangeRequired ?? () {}),
    ForbiddenInterceptor(onForbidden ?? () {}),
  ]);

  return dio;
}

final apiClientProvider = Provider<Dio>((ref) {
  final environment = ref.watch(environmentProvider);
  return createApiClient(
    environment: environment,
    isOnline: () => ref.read(isOnlineProvider),
    enableTracing: !environment.isProduction,
  );
});
