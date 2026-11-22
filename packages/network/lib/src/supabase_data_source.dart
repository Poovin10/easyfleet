import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dio_client.dart';

/// Thin wrapper over Supabase REST/RPC for project-specific endpoints.
class SupabaseDataSource {
  SupabaseDataSource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> select(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/rest/v1/$table',
      queryParameters: {
        'select': ?select,
        ...?filters,
      },
    );
    final data = response.data;
    if (data == null) return const [];
    // Supabase REST returns a JSON array; Dio decodes it as List<dynamic>.
    final list = (data is List
            ? data
            : (data as Map)['items'] as List<dynamic>? ?? const <dynamic>[])
        as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> rpc(String name, [Map<String, dynamic>? body]) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/rest/v1/rpc/$name',
      data: body ?? const <String, dynamic>{},
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<void> insert(String table, Map<String, dynamic> row) {
    return _dio.post<void>('/rest/v1/$table', data: row);
  }

  Future<void> update(
    String table,
    Map<String, dynamic> values, {
    required String filterColumn,
    required String filterValue,
  }) {
    return _dio.patch<void>(
      '/rest/v1/$table',
      queryParameters: {filterColumn: 'eq.$filterValue'},
      data: values,
    );
  }
}

final supabaseDataSourceProvider = Provider<SupabaseDataSource>((ref) {
  return SupabaseDataSource(ref.watch(apiClientProvider));
});

/// Direct Supabase client for Auth, Storage and Realtime.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
