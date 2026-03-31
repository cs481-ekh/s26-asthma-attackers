import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

import '../models/recommendation_args.dart';
import '../pages/recommendation_page.dart';
import '../utils/location_validator.dart';
import '../widgets/symptom_modal.dart';

/// Main entry page: symptom selection and location input.
/// Location can be entered as ZIP/city or approved via device geolocation.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SymptomLevel? _symptomLevel;
  final TextEditingController _locationController = TextEditingController();
  final _locationFocus = FocusNode();

  bool _useDeviceLocation = false;
  double? _latitude;
  double? _longitude;
  bool _locationLoading = false;
  String? _locationError;
  String? _locationValidationError;

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  Future<void> _openAqiInfo() async {
    final uri = Uri.parse('https://www.airnow.gov/?city=Boise&state=ID&country=USA');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openSymptomModal() async {
    final selected = await SymptomModal.show(context, current: _symptomLevel);
    if (selected != null && mounted) {
      setState(() => _symptomLevel = selected);
    }
  }

  /// On web, entry field is required (ZIP or city). On mobile, device location OR entry field.
  bool get _hasLocation {
    final entryText = _locationController.text.trim();
    final entryValid = entryText.isNotEmpty && LocationValidator.isValid(entryText);
    if (kIsWeb) {
      return entryValid;
    }
    return (_useDeviceLocation && _latitude != null && _longitude != null) || entryValid;
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _locationError = null;
      _locationLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      setState(() {
        _locationLoading = false;
        _locationError = 'Location services are disabled. Enable them in device settings.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied && mounted) {
      setState(() {
        _locationLoading = false;
        _locationError = 'Location permission was denied. Enter a ZIP code or city instead.';
      });
      return;
    }
    if (permission == LocationPermission.deniedForever && mounted) {
      setState(() {
        _locationLoading = false;
        _locationError = 'Location is permanently denied. Enter a ZIP code or city instead.';
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _useDeviceLocation = true;
          _locationLoading = false;
          _locationError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationLoading = false;
          _locationError = 'Could not get location. Try again or enter a ZIP code or city.';
        });
      }
    }
  }

  void _clearDeviceLocation() {
    setState(() {
      _useDeviceLocation = false;
      _latitude = null;
      _longitude = null;
      _locationError = null;
    });
  }

  void _onLocationTextChanged() {
    setState(() {
      if (_locationController.text.trim().isNotEmpty) {
        _useDeviceLocation = false;
      }
      _locationValidationError = null;
    });
  }

  void _getRecommendation() {
    if (_symptomLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a symptom level first.'),
        ),
      );
      return;
    }

    final entryText = _locationController.text.trim();
    final usingEntryField = !_useDeviceLocation || _latitude == null || _longitude == null;
    if (usingEntryField) {
      final validationError = LocationValidator.validate(entryText);
      if (validationError != null) {
        setState(() => _locationValidationError = validationError);
        return;
      }
    }

    if (!_hasLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
                ? 'Enter a ZIP code or city name to get air quality.'
                : 'Use "Use my location" or enter a ZIP code or city to get air quality.',
          ),
        ),
      );
      return;
    }

    final locationLabel = _useDeviceLocation && _latitude != null && _longitude != null
        ? 'Current location'
        : entryText;

    setState(() => _locationValidationError = null);

    Navigator.of(context).pushNamed(
      RecommendationPage.routeName,
      arguments: RecommendationArgs(
        symptomLevel: _symptomLevel!,
        location: locationLabel,
        latitude: _latitude,
        longitude: _longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asthma Activity Advisor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'An App for Asthma Warriors',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Child\'s symptom level',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _openSymptomModal,
                        icon: const Icon(Icons.arrow_drop_down, size: 24),
                        label: Text(
                          _symptomLevel != null
                              ? '${_symptomLevel!.id}: ${_symptomLevel!.label}'
                              : 'Select symptom level',
                        ),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location for air quality',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                          children: [
                            TextSpan(
                              text: kIsWeb
                                  ? 'Enter a ZIP code or city name (required on web). '
                                  : 'Use your device location or enter a ZIP code or city. ',
                            ),
                            TextSpan(
                              text: 'Learn more about AQI.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _openAqiInfo,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!kIsWeb && _useDeviceLocation && _latitude != null && _longitude != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Using your location',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              TextButton(
                                onPressed: _clearDeviceLocation,
                                child: const Text('Change'),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        TextField(
                          controller: _locationController,
                          focusNode: _locationFocus,
                          onChanged: (_) => _onLocationTextChanged(),
                          decoration: InputDecoration(
                            hintText: 'e.g. 83702 or Boise',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            errorText: _locationValidationError,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _getRecommendation(),
                        ),
                        if (!kIsWeb) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _locationLoading ? null : _useMyLocation,
                            icon: _locationLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location, size: 20),
                            label: Text(_locationLoading ? 'Getting location…' : 'Use my location'),
                          ),
                        ],
                      ],
                      if (_locationError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _locationError!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _symptomLevel == null || !_hasLocation ? null : _getRecommendation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Get activity recommendation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
