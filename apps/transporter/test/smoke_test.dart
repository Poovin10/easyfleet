import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:easyfleet_transporter/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('transporter app compiles and shared routes resolve', () {
    expect(const TransporterApp(), isA<TransporterApp>());
    expect(AppRoutes.fleetMap, '/fleet-map');
  });
}
