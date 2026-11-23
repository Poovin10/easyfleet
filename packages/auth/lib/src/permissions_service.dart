import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

/// Permissions are derived from active company memberships in the live schema.
///
/// The legacy `user_permissions` table does not exist. The backend uses
/// `company_memberships.role/status` plus SECURITY DEFINER helper functions.
final userPermissionsProvider = FutureProvider<List<String>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final userId = authState.userId;
  if (userId == null) return const <String>[];

  final client = ref.watch(supabaseClientProvider);
  final rows = await client
      .from(Tables.companyMemberships)
      .select('company_id, role, status')
      .eq('user_id', userId)
      .eq('status', 'ACTIVE');

  final permissions = <String>{'fleet:read'};
  for (final row in rows) {
    final companyId = row['company_id'] as String?;
    final role = row['role'] as String?;
    if (companyId == null || role == null || role.isEmpty) continue;

    permissions
      ..add('company:$companyId:member')
      ..add('company:$companyId:${role.toLowerCase()}');

    if (role == 'OWNER' || role == 'ADMIN') {
      permissions.add('company:$companyId:manager');
    } else if (role == 'COMPLIANCE') {
      permissions.add('company:$companyId:compliance');
    } else if (role == 'DISPATCHER') {
      permissions.add('company:$companyId:dispatcher');
    } else if (role == 'VIEWER') {
      permissions.add('company:$companyId:viewer');
    }
  }

  return permissions.toList()..sort();
});

bool hasPermission(List<String> permissions, String permission) {
  return permissions.contains(permission) || permissions.contains('*');
}
