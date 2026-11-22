import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

/// Permissions come from Supabase RLS-backed tables, not WonderMove's Kratos API.
final userPermissionsProvider = FutureProvider<List<String>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final userId = authState.userId;
  if (userId == null) return const <String>[];

  final client = ref.watch(supabaseClientProvider);
  final rows = await client
      .from('user_permissions')
      .select('permission')
      .eq('user_id', userId);

  return rows
      .map((row) => row['permission'] as String)
      .where((permission) => permission.isNotEmpty)
      .toList();
});

bool hasPermission(List<String> permissions, String permission) {
  return permissions.contains(permission) || permissions.contains('*');
}
