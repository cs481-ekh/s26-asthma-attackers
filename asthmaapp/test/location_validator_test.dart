import 'package:asthmaapp/utils/location_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationValidator.validate', () {
    test('returns null for a valid 5-digit ZIP code', () {
      expect(LocationValidator.validate('83702'), isNull);
    });

    test('returns null for a valid city name', () {
      expect(LocationValidator.validate('Boise'), isNull);
    });

    test('returns an error for an empty string', () {
      expect(
        LocationValidator.validate('   '),
        'Enter a ZIP code or city name.',
      );
    });

    test('returns an error for overly long input', () {
      expect(
        LocationValidator.validate('A' * 101),
        'Enter a valid 5-digit ZIP code (e.g. 83702) or a city name (e.g. Boise).',
      );
    });

    test('returns an error for special characters', () {
      expect(
        LocationValidator.validate('Boise@123'),
        'Enter a valid 5-digit ZIP code (e.g. 83702) or a city name (e.g. Boise).',
      );
    });
  });
}