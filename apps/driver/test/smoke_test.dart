import 'package:easyfleet_auth/easyfleet_auth.dart';
import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_driver/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('driver app compiles and deep links parse', () {
    expect(const DriverApp(), isA<DriverApp>());
    expect(
      DeepLinks.tripIdFromUri(
        Uri.parse('https://app.easyfleet.in/trip/trip-42'),
      ),
      'trip-42',
    );
  });

  test('email confirmation callbacks open the native apps', () {
    expect(
      authRedirectForRole('driver'),
      'com.easyfleet.driver://auth/callback',
    );
    expect(
      authRedirectForRole('transporter'),
      'com.easyfleet.transporter://auth/callback',
    );
  });
}
