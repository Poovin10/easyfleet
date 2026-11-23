import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'supabase_data_source.dart';
import 'supabase_tables.dart';

const _uuid = Uuid();

/// Generates client-side UUIDs for idempotent writes (native queue contract).
String newId() => _uuid.v4();

final companyServiceProvider = Provider<CompanyService>((ref) {
  return CompanyService(ref.watch(supabaseClientProvider));
});

/// Company registration, membership and profile access.
class CompanyService {
  CompanyService(this._client);

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Registers a company and makes the caller its OWNER.
  Future<String> registerCompany({
    required String name,
    String? legalName,
  }) async {
    final companyId = newId();
    await _client.rpc<dynamic>(
      RpcNames.createCompany,
      params: {
        'p_company_id': companyId,
        'p_name': name.trim(),
        'p_legal_name': legalName?.trim(),
      },
    );
    return companyId;
  }

  /// Active memberships of the signed-in user, with company names.
  Future<List<CompanyMembership>> myMemberships() async {
    final userId = _userId;
    if (userId == null) return const [];
    final rows = await _client
        .from(Tables.companyMemberships)
        .select('*, companies(name)')
        .eq('user_id', userId)
        .order('created_at');
    return rows.map(CompanyMembership.fromJson).toList();
  }

  Future<Company?> company(String companyId) async {
    final row = await _client
        .from(Tables.companies)
        .select()
        .eq('id', companyId)
        .maybeSingle();
    return row == null ? null : Company.fromJson(row);
  }

  /// The driver account of the signed-in user, if any.
  Future<DriverAccount?> myDriverAccount() async {
    final userId = _userId;
    if (userId == null) return null;
    final row = await _client
        .from(Tables.driverAccounts)
        .select()
        .eq('auth_user_id', userId)
        .maybeSingle();
    return row == null ? null : DriverAccount.fromJson(row);
  }

  /// Companies the signed-in driver holds an approved membership in.
  Future<List<DriverMembership>> myDriverMemberships() async {
    final account = await myDriverAccount();
    if (account == null) return const [];
    final rows = await _client
        .from(Tables.driverMemberships)
        .select('*, companies(name)')
        .eq('driver_account_id', account.id)
        .order('created_at');
    return rows.map(DriverMembership.fromJson).toList();
  }
}

/// Shared selected-company context for the transporter app.
final selectedCompanyProvider = NotifierProvider<SelectedCompany, String?>(
  SelectedCompany.new,
);

class SelectedCompany extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? companyId) => state = companyId;
}

/// Loads the first active manager membership as the default company.
final defaultCompanyProvider = FutureProvider<CompanyMembership?>((ref) async {
  final memberships = await ref.watch(companyServiceProvider).myMemberships();
  final active = memberships.where((m) => m.isActive).toList();
  if (active.isEmpty) return null;
  active.sort((a, b) {
    int rank(CompanyMembership m) => m.isManager ? 0 : 1;
    return rank(a).compareTo(rank(b));
  });
  return active.first;
});

/// Current auth user id as a stream (initial value included).
final authUserIdProvider = StreamProvider<String?>((ref) async* {
  final client = ref.watch(supabaseClientProvider);
  yield client.auth.currentUser?.id;
  yield* client.auth.onAuthStateChange
      .map((event) => event.session?.user.id)
      .distinct();
});

/// The signed-in driver's account row, rebuilt on auth changes.
final driverAccountProvider = FutureProvider<DriverAccount?>((ref) async {
  final userId = ref.watch(authUserIdProvider).value;
  if (userId == null) return null;
  return ref.watch(companyServiceProvider).myDriverAccount();
});

/// Approved company memberships of the signed-in driver.
final driverMembershipsProvider = FutureProvider<List<DriverMembership>>((
  ref,
) async {
  final account = ref.watch(driverAccountProvider).value;
  if (account == null) return const [];
  return ref.watch(companyServiceProvider).myDriverMemberships();
});
