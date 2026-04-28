import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/recommendation_args.dart';
import '../pages/recommendation_page.dart';
import '../services/locale_service.dart';
import '../utils/location_validator.dart';
import '../widgets/bottom_logos_bar.dart';
import '../widgets/symptom_modal.dart';
import '../widgets/section_header_with_info.dart';

/// Main entry page: symptom selection and location input.
/// Location can be entered as ZIP/city or approved via device geolocation.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.localeNotifier});

  final ValueNotifier<Locale?> localeNotifier;

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

  void _showAsthmaInfoDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;

        Widget bullet(String text) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(text)),
              ],
            ),
          );
        }

        return AlertDialog(
          title: Text(l10n.asthmaInfoTitle),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.asthmaSymptomsTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                bullet(l10n.asthmaSymptomBullet1),
                bullet(l10n.asthmaSymptomBullet2),
                bullet(l10n.asthmaSymptomBullet3),
                bullet(l10n.asthmaSymptomBullet4),
                bullet(l10n.asthmaSymptomBullet5),
                bullet(l10n.asthmaSymptomBullet6),
                bullet(l10n.asthmaSymptomBullet7),

                const SizedBox(height: 16),

                Text(
                  l10n.asthmaTriggersTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                bullet(l10n.asthmaTriggerBullet1),
                bullet(l10n.asthmaTriggerBullet2),
                bullet(l10n.asthmaTriggerBullet3),
                bullet(l10n.asthmaTriggerBullet4),
                bullet(l10n.asthmaTriggerBullet5),
                bullet(l10n.asthmaTriggerBullet6),
                bullet(l10n.asthmaTriggerBullet7),
                bullet(l10n.asthmaTriggerBullet8),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.actionClose),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAirNowDetails() async {
    final uri = Uri.parse(
      'https://www.airnow.gov/?city=Boise&state=ID&country=USA',
    );

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
    final entryValid =
        entryText.isNotEmpty && LocationValidator.isValid(entryText);
    if (kIsWeb) {
      return entryValid;
    }
    return (_useDeviceLocation && _latitude != null && _longitude != null) ||
        entryValid;
  }

  Future<void> _useMyLocation() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _locationError = null;
      _locationLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      setState(() {
        _locationLoading = false;
        _locationError = l10n.locationServicesDisabled;
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
        _locationError = l10n.locationPermissionDenied;
      });
      return;
    }
    if (permission == LocationPermission.deniedForever && mounted) {
      setState(() {
        _locationLoading = false;
        _locationError = l10n.locationPermissionDeniedForever;
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
          _locationError = l10n.locationFetchFailed;
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
    final l10n = AppLocalizations.of(context);
    if (_symptomLevel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.snackSelectSymptomFirst)));
      return;
    }

    final entryText = _locationController.text.trim();
    final usingEntryField =
        !_useDeviceLocation || _latitude == null || _longitude == null;
    if (usingEntryField) {
      final validationError = LocationValidator.validate(entryText);
      if (validationError != null) {
        setState(
          () => _locationValidationError = _localizedValidationError(
            validationError,
            l10n,
          ),
        );
        return;
      }
    }

    if (!_hasLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
                ? l10n.snackEnterZipOrCityWeb
                : l10n.snackEnterZipOrCityMobile,
          ),
        ),
      );
      return;
    }

    final locationLabel =
        _useDeviceLocation && _latitude != null && _longitude != null
        ? l10n.currentLocation
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              if (value == 'about') {
                Navigator.pushNamed(context, '/about');
              } else if (value == 'language') {
                _openLanguagePicker(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'about', child: Text(l10n.menuAbout)),
              PopupMenuItem(value: 'language', child: Text(l10n.menuLanguage)),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const BottomLogosBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                decoration: AppTheme.homeHeroDecoration(),
                child: Column(
                  children: [
                    Text(
                      l10n.homeHeroTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.homeHeroSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                container: true,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: 
                            SectionHeaderWithInfo(
                            title: l10n.symptomLevelTitle,
                            onInfoPressed: _showAsthmaInfoDialog,
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _openSymptomModal,
                          icon: const Icon(Icons.arrow_drop_down, size: 24),
                          label: Text(
                            _symptomLevel != null
                                ? '${_symptomLevel!.id}: ${_symptomLevel!.localizedLabel(l10n)}'
                                : l10n.selectSymptomLevel,
                          ),
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Semantics(
                container: true,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.locationTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: kIsWeb
                                    ? l10n.locationHelperWeb
                                    : l10n.locationHelperMobile,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  height: 1.45,
                                ),
                              ),
                              TextSpan(
                                text: l10n.moreDetails,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _openAirNowDetails,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (!kIsWeb &&
                            _useDeviceLocation &&
                            _latitude != null &&
                            _longitude != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                ExcludeSemantics(
                                  child: Icon(
                                    Icons.location_on,
                                    color: theme.colorScheme.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.usingYourLocation,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _clearDeviceLocation,
                                  child: Text(l10n.actionChange),
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
                              labelText: l10n.zipOrCityLabel,
                              hintText: l10n.zipOrCityHint,
                              prefixIcon: ExcludeSemantics(
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              errorText: _locationValidationError,
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _getRecommendation(),
                          ),
                          if (!kIsWeb) ...[
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: _locationLoading
                                  ? null
                                  : _useMyLocation,
                              icon: _locationLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Semantics(
                                        label: l10n.loadingLocation,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.my_location, size: 22),
                              label: Text(
                                _locationLoading
                                    ? l10n.gettingLocation
                                    : l10n.useMyLocation,
                              ),
                            ),
                          ],
                        ],
                        if (_locationError != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _locationError!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _symptomLevel == null || !_hasLocation
                    ? null
                    : _getRecommendation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppTheme.bsuOrange,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.getRecommendation),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLanguagePicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final current = widget.localeNotifier.value?.languageCode ?? 'en';

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.languageTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                RadioListTile<String>(
                  value: 'en',
                  groupValue: current,
                  title: Text(l10n.languageEnglish),
                  onChanged: (v) => Navigator.of(context).pop(v),
                ),
                RadioListTile<String>(
                  value: 'es',
                  groupValue: current,
                  title: Text(l10n.languageSpanish),
                  onChanged: (v) => Navigator.of(context).pop(v),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.actionClose),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null) return;
    final locale = Locale(selected);
    widget.localeNotifier.value = locale;
    await LocaleService.save(locale);
  }

  static String _localizedValidationError(String error, AppLocalizations l10n) {
    if (error == 'Enter a ZIP code or city name.') {
      return l10n.validationEnterZipOrCity;
    }
    if (error ==
        'Enter a valid 5-digit ZIP code (e.g. 83702) or a city name (e.g. Boise).') {
      return l10n.validationInvalidZipOrCity;
    }
    return error;
  }
}
