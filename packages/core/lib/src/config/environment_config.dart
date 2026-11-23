import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Build-time configuration shared by both EasyFleet apps.
///
/// Values are injected with `--dart-define`, never committed to source control.
class EnvironmentConfig {
  const EnvironmentConfig._({
    required this.flavor,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.storageBucket,
    required this.deepLinkHost,
  });

  /// Resolved from `--dart-define=APP_FLAVOR=dev|staging|prod`.
  factory EnvironmentConfig.fromEnvironment() {
    final flavorName = const String.fromEnvironment(
      'APP_FLAVOR',
      defaultValue: 'prod',
    );
    final flavor = AppFlavorX.fromName(flavorName) ?? AppFlavor.prod;

    return EnvironmentConfig._(
      flavor: flavor,
      supabaseUrl: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://iktekjnisqmbjtoictnc.supabase.co',
      ),
      supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      storageBucket: const String.fromEnvironment(
        'SUPABASE_STORAGE_BUCKET',
        defaultValue: 'easyfleet-private-documents',
      ),
      deepLinkHost: const String.fromEnvironment(
        'DEEP_LINK_HOST',
        defaultValue: 'app.easyfleet.in',
      ),
    );
  }

  static final EnvironmentConfig instance = EnvironmentConfig.fromEnvironment();

  final AppFlavor flavor;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String storageBucket;
  final String deepLinkHost;

  bool get isProduction => flavor == AppFlavor.prod;

  @override
  String toString() => 'EnvironmentConfig($flavor, $supabaseUrl)';
}

enum AppFlavor { dev, staging, prod }

extension AppFlavorX on AppFlavor {
  static AppFlavor? fromName(String name) {
    for (final value in AppFlavor.values) {
      if (value.name == name.toLowerCase()) return value;
    }
    return null;
  }
}

/// Provider used throughout the app tree.
final environmentProvider = Provider<EnvironmentConfig>(
  (ref) => EnvironmentConfig.instance,
);

/// Version gates are build-time constants so no network call is needed before
/// the first render. CI can raise the floor with
/// `--dart-define=MINIMUM_APP_VERSION=x.y.z` without touching source.
final currentAppVersionProvider = Provider<String>(
  (ref) => const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0'),
);

final minimumSupportedVersionProvider = Provider<String>(
  (ref) => const String.fromEnvironment(
    'MINIMUM_APP_VERSION',
    defaultValue: '1.0.0',
  ),
);
