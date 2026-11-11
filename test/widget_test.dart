import 'package:auth_lab/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('email', () {
    test('rejects empty', () => expect(Validators.email(''), isNotNull));
    test('rejects missing @', () => expect(Validators.email('test.example.com'), isNotNull));
    test('rejects missing domain dot', () => expect(Validators.email('a@b'), isNotNull));
    test('accepts valid', () => expect(Validators.email('test@example.com'), isNull));
  });

  group('password', () {
    test('rejects empty', () => expect(Validators.password(''), isNotNull));
    test('rejects 5 chars', () => expect(Validators.password('12345'), isNotNull));
    test('accepts 6 chars', () => expect(Validators.password('123456'), isNull));
  });
}
