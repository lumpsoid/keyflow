import 'package:flutter_test/flutter_test.dart';
import 'package:keyflow/app_version.dart';

void main() {
  test('shows the commit when the build has one', () {
    expect(versionLabel('0.1.0', '2391c1d'), '0.1.0 (2391c1d)');
    expect(versionLabel('dev', ''), 'dev');
  });
}
