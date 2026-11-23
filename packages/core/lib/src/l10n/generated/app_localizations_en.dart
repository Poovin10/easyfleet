// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EasyFleet';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get trips => 'Trips';

  @override
  String get liveTracking => 'Live tracking';

  @override
  String get inspections => 'Inspections';

  @override
  String get alerts => 'Alerts';

  @override
  String get settings => 'Settings';

  @override
  String get map => 'Map';

  @override
  String get offline => 'You are offline';

  @override
  String get retry => 'Retry';

  @override
  String get noData => 'Nothing here yet';

  @override
  String get loading => 'Loading…';

  @override
  String get error => 'Something went wrong';

  @override
  String get currentTrip => 'Current trip';

  @override
  String get wallet => 'Wallet';

  @override
  String get payouts => 'Payouts';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get dispatch => 'Dispatch';

  @override
  String get loadingReceipts => 'Loading receipts';

  @override
  String get unloadTrips => 'Unload trips';

  @override
  String get signUp => 'Sign up';

  @override
  String get fullName => 'Full name';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign up';

  @override
  String get checkYourEmail =>
      'Account created. Check your email to confirm, then sign in.';

  @override
  String get signUpSuccess => 'Account created.';

  @override
  String get nameRequired => 'Enter your name';

  @override
  String get passwordTooShort => 'Use at least 6 characters';

  @override
  String get passwordMismatch => 'Passwords do not match';
}
