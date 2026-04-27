import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/aqi_result.dart';
import '../models/recommendation_args.dart';
import '../services/aqi_service.dart';
import '../services/airnow_aqi_service.dart';
import '../services/locale_service.dart';
import '../widgets/airnow_forecast_widget.dart';
import '../widgets/bottom_logos_bar.dart';
import '../widgets/symptom_modal.dart';
import '../services/slide_rule_service.dart';

/// Resolves city + state for the embedded AirNow dial URL.
///
/// The EPA widget usually needs a US state. If the user typed only a city
/// (e.g. "Boise"), [AqiData.stateCode] and [AqiData.reportingArea] from a
/// successful API response are merged in so the embed matches the API data.
({String city, String? state})? cityStateForAirNowEmbed({
  required String location,
  required AqiResult? aqiResult,
}) {
  var cityState = parseCityStateForAirNow(location);

  if (cityState == null && aqiResult is AqiSuccess) {
    final data = aqiResult.data;
    final area = data.reportingArea;
    if (area != null && area.isNotEmpty) {
      cityState = (city: area, state: data.stateCode);
    }
  }

  if (cityState != null && aqiResult is AqiSuccess) {
    final data = aqiResult.data;
    final stateMissing =
        cityState.state == null || cityState.state!.trim().isEmpty;
    if (stateMissing &&
        data.stateCode != null &&
        data.stateCode!.trim().isNotEmpty) {
      final apiCity = data.reportingArea?.trim();
      final city = (apiCity != null && apiCity.isNotEmpty)
          ? apiCity
          : cityState.city;
      cityState = (city: city, state: data.stateCode);
    }
  }

  return cityState;
}

/// Tries to extract city and state from a location string for the AirNow embed.
///
/// Handles these formats:
///  - "City, ST"  → city + 2-letter state abbreviation
///  - "City"      → city only (state is null)
///
/// Returns null for ZIP codes (5 digits) and "Current location" strings
/// since the AirNow widget requires a city name, not a ZIP or coordinates.
({String city, String? state})? parseCityStateForAirNow(String location) {
  final trimmed = location.trim();
  final lower = trimmed.toLowerCase();
  if (trimmed.isEmpty ||
      lower == 'current location' ||
      lower == 'ubicación actual') {
    return null;
  }
  // Reject plain ZIP codes (5-digit or ZIP+4)
  if (RegExp(r'^\d{5}(-\d{4})?$').hasMatch(trimmed)) return null;
  // Match "City, ST" with a 2-letter state abbreviation
  final match = RegExp(r'^(.+?),\s*([A-Za-z]{2})$').firstMatch(trimmed);
  if (match != null) {
    return (city: match.group(1)!.trim(), state: match.group(2)!.toUpperCase());
  }
  // Plain city name with no state
  return (city: trimmed, state: null);
}

/// Displays activity recommendation based on symptom level and AQI.
/// Fetches AQI using user-provided location (ZIP/city); displays most recent
/// or handles failed API calls with retry and optional last-known AQI.
class RecommendationPage extends StatefulWidget {
  const RecommendationPage({
    super.key,
    this.aqiService,
    required this.localeNotifier,
  });

  static const String routeName = '/recommendation';

  final AqiService? aqiService;
  final ValueNotifier<Locale?> localeNotifier;

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  AqiService get _aqiService => widget.aqiService ?? AirNowAqiService();

  RecommendationArgs? _args;
  AqiResult? _aqiResult;
  bool _loading = false;

  Recommendation? _lightRecommendation;
  Recommendation? _moderateRecommendation;
  Recommendation? _vigorousRecommendation;

  String get _location => _args?.location ?? '';

  ({Recommendation light, Recommendation moderate, Recommendation vigorous})
  _recommendationsForCategory(String category, SymptomLevel symptomLevel) {
    final aqiColor = mapAqiCategory(category);
    return (
      light: SlideRuleService.getRecommendation(
        aqiColor: aqiColor,
        activityLevel: ActivityLevel.light,
        symptomLevel: symptomLevel,
      ),
      moderate: SlideRuleService.getRecommendation(
        aqiColor: aqiColor,
        activityLevel: ActivityLevel.moderate,
        symptomLevel: symptomLevel,
      ),
      vigorous: SlideRuleService.getRecommendation(
        aqiColor: aqiColor,
        activityLevel: ActivityLevel.vigorous,
        symptomLevel: symptomLevel,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is RecommendationArgs && args != _args) {
      _args = args;
      if (args.useCoordinates) {
        _fetchAqi();
      } else if (args.location.trim().isNotEmpty) {
        _fetchAqi();
      } else {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _aqiResult = AqiFailure(
            message: l10n.recommendationMissingLocationMessage,
          );
        });
      }
    }
  }

  Future<void> _fetchAqi() async {
    final args = _args;
    if (args == null) return;
    setState(() {
      _loading = true;
      _aqiResult = null;
    });
    final AqiResult result;
    if (args.useCoordinates &&
        args.latitude != null &&
        args.longitude != null) {
      result = await _aqiService.getAqiForCoordinates(
        args.latitude!,
        args.longitude!,
        locationLabel: args.location,
      );
    } else if (args.location.trim().isNotEmpty) {
      result = await _aqiService.getAqiForLocation(args.location);
    } else {
      final l10n = AppLocalizations.of(context);
      result = AqiFailure(message: l10n.recommendationNoLocationProvided);
    }
    if (mounted) {
      setState(() {
        _loading = false;
        _aqiResult = result;

        if (result is AqiSuccess && _args?.symptomLevel != null) {
          final recommendations = _recommendationsForCategory(
            result.data.category,
            _args!.symptomLevel,
          );

          _lightRecommendation = recommendations.light;
          _moderateRecommendation = recommendations.moderate;
          _vigorousRecommendation = recommendations.vigorous;
        }
      });
    }
  }

  void _openNextDayGuidance() {
    final args = _args;
    final symptomLevel = args?.symptomLevel;
    if (args == null || symptomLevel == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      builder: (_) => _NextDayGuidanceSheet(
        aqiService: _aqiService,
        args: args,
        recommendationsForCategory: _recommendationsForCategory,
      ),
    );
  }

  /// Builds the air quality section: the embedded AirNow forecast widget when
  /// a parseable city name is available, or the plain [_AqiCard] fallback for
  /// ZIP codes and GPS-only locations.
  Widget _buildAqiDisplay() {
    final cityState = cityStateForAirNowEmbed(
      location: _location,
      aqiResult: _aqiResult,
    );

    if (cityState != null && _aqiResult is AqiSuccess) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(Icons.air, color: AppTheme.bsuBlue, size: 28),
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    header: true,
                    child: Text(
                      AppLocalizations.of(context).airQualityTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  Center(
                    child: AirNowForecastWidget(
                      key: ValueKey(
                        'airnow-${cityState.city}-${cityState.state ?? ''}',
                      ),
                      city: cityState.city,
                      state: cityState.state,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () async {
                        final uri = Uri.parse(
                          'https://www.airnow.gov/aqi/aqi-basics/',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context).moreDetails,
                        style: const TextStyle(
                          color: AppTheme.linkColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    // Fallback for ZIP codes or GPS (no city/state available for the widget URL)
    return _AqiCard(
      location: _location,
      aqiResult: _aqiResult,
      loading: _loading,
      onRetry: _fetchAqi,
    );
  }

  @override
  Widget build(BuildContext context) {
    final symptomLevel = _args?.symptomLevel;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recommendationTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.goBack,
          onPressed: () => Navigator.of(context).pop(),
        ),

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
              _buildAqiDisplay(),
              const SizedBox(height: 20),
              _RecommendationCard(
                symptomLevel: symptomLevel,
                lightRecommendation: _lightRecommendation,
                moderateRecommendation: _moderateRecommendation,
                vigorousRecommendation: _vigorousRecommendation,
                l10n: l10n,
              ),
              const SizedBox(height: 20),
              _ExplanationCard(
                symptomLevel: symptomLevel,
                aqiColor: _aqiResult is AqiSuccess
                    ? mapAqiCategory((_aqiResult as AqiSuccess).data.category)
                    : null,
                l10n: l10n,
              ),
              const SizedBox(height: 20),
              _DisclaimerCard(l10n: l10n),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _openNextDayGuidance,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(l10n.nextDayGuidanceButton),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
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
}

class _NextDayGuidanceSheet extends StatefulWidget {
  const _NextDayGuidanceSheet({
    required this.aqiService,
    required this.args,
    required this.recommendationsForCategory,
  });

  final AqiService aqiService;
  final RecommendationArgs args;
  final ({
    Recommendation light,
    Recommendation moderate,
    Recommendation vigorous,
  })
  Function(String category, SymptomLevel symptomLevel)
  recommendationsForCategory;

  @override
  State<_NextDayGuidanceSheet> createState() => _NextDayGuidanceSheetState();
}

class _NextDayGuidanceSheetState extends State<_NextDayGuidanceSheet> {
  AqiResult? _nextDayResult;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNextDayForecast();
  }

  Future<void> _fetchNextDayForecast() async {
    setState(() {
      _loading = true;
      _nextDayResult = null;
    });

    final args = widget.args;
    final AqiResult result;
    if (args.useCoordinates &&
        args.latitude != null &&
        args.longitude != null) {
      result = await widget.aqiService.getForecastForCoordinates(
        args.latitude!,
        args.longitude!,
        locationLabel: args.location,
        dayOffset: 1,
      );
    } else {
      result = await widget.aqiService.getForecastForLocation(
        args.location,
        dayOffset: 1,
      );
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
      _nextDayResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final symptomLevel = widget.args.symptomLevel;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.nextDayGuidanceTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.nextDayGuidanceSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Semantics(
                      label: l10n.loadingNextDayForecast,
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (_nextDayResult is AqiFailure)
                _AqiCard(
                  location: widget.args.location,
                  aqiResult: _nextDayResult,
                  loading: false,
                  onRetry: _fetchNextDayForecast,
                )
              else if (_nextDayResult case AqiSuccess(:final data)) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.forecastAqiLabel(data.aqiValue, data.category),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.locationLabelValue(data.locationLabel),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (_) {
                    final recommendations = widget.recommendationsForCategory(
                      data.category,
                      symptomLevel,
                    );
                    return _RecommendationCard(
                      symptomLevel: symptomLevel,
                      lightRecommendation: recommendations.light,
                      moderateRecommendation: recommendations.moderate,
                      vigorousRecommendation: recommendations.vigorous,
                      l10n: l10n,
                    );
                  },
                ),
              ],
              const SizedBox(height: 12),
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
      ),
    );
  }
}

class _AqiCard extends StatelessWidget {
  const _AqiCard({
    required this.location,
    required this.aqiResult,
    required this.loading,
    required this.onRetry,
  });

  final String location;
  final AqiResult? aqiResult;
  final bool loading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: Icon(Icons.air, color: AppTheme.bsuBlue, size: 28),
                ),
                const SizedBox(width: 10),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.airQualityTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Semantics(
                        label: l10n.loadingAirQuality,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.loadingAirQualityEllipsis),
                  ],
                ),
              )
            else if (aqiResult == null)
              Text(
                location.isEmpty
                    ? l10n.enterLocationForAqi
                    : l10n.locationLabelValue(location),
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...switch (aqiResult!) {
                AqiSuccess(data: final data, lastUpdated: final lastUpdated) =>
                  [
                    Text(
                      l10n.locationLabelValue(data.locationLabel),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.aqiLabelValue(data.aqiValue, data.category),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (lastUpdated != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.updatedRelative(_formatTime(context, lastUpdated)),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                AqiFailure(
                  message: final message,
                  lastKnown: final lastKnown,
                ) =>
                  [
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    if (lastKnown != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        l10n.lastKnownAqi(
                          lastKnown.aqiValue,
                          lastKnown.category,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n.actionRetry),
                    ),
                  ],
              },
          ],
        ),
      ),
    );
  }

  static String _formatTime(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return l10n.relativeJustNow;
    if (diff.inMinutes < 60) return l10n.relativeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.relativeHoursAgo(diff.inHours);
    return l10n.relativeDaysAgo(diff.inDays);
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    this.symptomLevel,
    this.lightRecommendation,
    this.moderateRecommendation,
    this.vigorousRecommendation,
    required this.l10n,
  });

  final SymptomLevel? symptomLevel;
  final Recommendation? lightRecommendation;
  final Recommendation? moderateRecommendation;
  final Recommendation? vigorousRecommendation;
  final AppLocalizations l10n;

  /// Dark green / red for icon + text contrast on light backgrounds (not sole indicator).
  static const Color _okGreen = Color(0xFF0D5C2E);
  static const Color _notOkRed = Color(0xFFB71C1C);

  Widget _activityRow(
    BuildContext context,
    String label,
    Recommendation? result,
  ) {
    if (result == null) {
      return Text(
        l10n.activityLoading(label),
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
      );
    }

    final isOk = result == Recommendation.ok;
    final statusText = isOk
        ? l10n.activityRecommended
        : l10n.activityNotRecommended;

    return Semantics(
      label: '$label: $statusText',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isOk ? Icons.check_circle : Icons.cancel,
            color: isOk ? _okGreen : _notOkRed,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: $statusText',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.35,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.bsuBlue.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.recommendedActivityTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (symptomLevel == null)
              Text(
                l10n.recommendationPendingMessage,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: AppTheme.textSecondary,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _activityRow(
                    context,
                    l10n.lightActivity,
                    lightRecommendation,
                  ),
                  const SizedBox(height: 10),
                  _activityRow(
                    context,
                    l10n.mediumActivity,
                    moderateRecommendation,
                  ),
                  const SizedBox(height: 10),
                  _activityRow(
                    context,
                    l10n.vigorousActivity,
                    vigorousRecommendation,
                  ),

                  const SizedBox(height: 16),

                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(
                      left: 4,
                      right: 4,
                      bottom: 8,
                    ),
                    title: Text(
                      l10n.activityExamplesTitle,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    children: [
                      _ActivityExampleSection(
                        title: l10n.lightActivity,
                        imageAsset: 'assets/images/mmiroshnichenko.jpg',
                        examples: [
                          l10n.exampleLight1,
                          l10n.exampleLight2,
                          l10n.exampleLight3,
                          l10n.exampleLight4,
                          l10n.exampleLight5,
                          l10n.exampleLight6,
                          l10n.exampleLight7,
                        ],
                      ),
                      const SizedBox(height: 10),
                      _ActivityExampleSection(
                        title: l10n.mediumActivity,
                        imageAsset: 'assets/images/pixabay.jpg',
                        examples: [
                          l10n.exampleModerate1,
                          l10n.exampleModerate2,
                          l10n.exampleModerate3,
                          l10n.exampleModerate4,
                          l10n.exampleModerate5,
                          l10n.exampleModerate6,
                          l10n.exampleModerate7,
                        ],
                      ),
                      const SizedBox(height: 10),
                      _ActivityExampleSection(
                        title: l10n.vigorousActivity,
                        imageAsset: 'assets/images/jim-de-ramos.jpg',
                        examples: [
                          l10n.exampleVigorous1,
                          l10n.exampleVigorous2,
                          l10n.exampleVigorous3,
                          l10n.exampleVigorous4,
                          l10n.exampleVigorous5,
                          l10n.exampleVigorous6,
                        ],
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    this.symptomLevel,
    this.aqiColor,
    required this.l10n,
  });

  final SymptomLevel? symptomLevel;
  final AqiColor? aqiColor;
  final AppLocalizations l10n;

  String _getExplanation() {
    if (symptomLevel == null || aqiColor == null) {
      return l10n.explanationPending;
    }

    switch (aqiColor) {
      case AqiColor.green:
        return l10n.explanationGreen;

      case AqiColor.yellow:
        return l10n.explanationYellow;

      case AqiColor.orange:
        return l10n.explanationOrange;

      case AqiColor.red:
        return l10n.explanationRed;

      case AqiColor.purple:
        return l10n.explanationPurple;

      default:
        return l10n.explanationUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.whyRecommendationTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getExplanation(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse(
                      'https://www.boisestate.edu/research-resilience/resources-hazards/air-quality-and-smoke/',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Text(
                    l10n.moreInformation,
                    style: const TextStyle(
                      color: AppTheme.linkColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard({required this.l10n});

  static const Color _amberBorder = Color(0xFFC67F00);
  static const Color _amberIcon = Color(0xFF8D5B00);
  static const Color _amberBg = Color(0xFFFFF8E6);
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _amberBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _amberBorder, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.health_and_safety_outlined,
                color: _amberIcon,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                container: true,
                child: Text(
                  l10n.disclaimerText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textPrimary,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityExampleSection extends StatelessWidget {
  final String title;
  final List<String> examples;
  final String? imageAsset;

  const _ActivityExampleSection({
    required this.title,
    required this.examples,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          // Use a fraction of the screen width for the image, with min/max bounds
          final imageSize = screenWidth * 0.28;
          final clampedSize = imageSize.clamp(72.0, 220.0);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Examples list and title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...examples.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 3),
                        child: Row(
                          children: [
                            const Text('• '),
                            Expanded(
                              child: Text(
                                e,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (imageAsset != null) ...[
                const SizedBox(width: 8),
                Image.asset(
                  imageAsset!,
                  width: clampedSize,
                  height: clampedSize,
                  fit: BoxFit.cover,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
