/// Validates location entry field input: accepts US ZIP code or city name.
///
/// - **ZIP code**: 5 digits, or 5 digits + hyphen + 4 digits (ZIP+4).
/// - **City name**: At least 2 characters; letters, spaces, hyphens, apostrophes only.
class LocationValidator {
  LocationValidator._();

  static final RegExp _zipCode = RegExp(r'^\d{5}(-\d{4})?$');
  static final RegExp _cityName = RegExp(r"^[a-zA-Z][a-zA-Z\s\-']{1,}$");

  /// Returns true if [input] is a valid US ZIP (5 or 5+4 digits).
  static bool isValidZipCode(String input) {
    final trimmed = input.trim();
    return trimmed.isNotEmpty && _zipCode.hasMatch(trimmed);
  }

  /// Returns true if [input] looks like a city name (2+ chars, letters/spaces/hyphens/apostrophes).
  static bool isValidCityName(String input) {
    final trimmed = input.trim();
    if (trimmed.length < 2) return false;
    return _cityName.hasMatch(trimmed);
  }

  /// Returns true if [input] is either a valid ZIP or a valid city name.
  static bool isValid(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    return isValidZipCode(trimmed) || isValidCityName(trimmed);
  }

  /// Returns null if valid; otherwise an error message for the user.
  static String? validate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return 'Enter a ZIP code or city name.';
    }
    if (isValidZipCode(trimmed) || isValidCityName(trimmed)) {
      return null;
    }
    return 'Enter a valid 5-digit ZIP code (e.g. 83702) or a city name (e.g. Boise).';
  }
}
