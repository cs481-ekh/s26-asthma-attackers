import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';
import '../models/aqi_result.dart';
import '../models/recommendation_args.dart';
import '../services/aqi_service.dart';
import '../services/airnow_aqi_service.dart';
import '../widgets/airnow_forecast_widget.dart';
import '../widgets/symptom_modal.dart';
import '../services/slide_rule_service.dart';

/// Resolves city + state for the embedded AirNow dial URL.
///
/// The EPA widget usually needs a US state. If the user typed only a city
/// (e.g. "Boise"), [AqiData.stateCode] and [AqiData.reportingArea] from a
/// successful API response are merged in so the embed matches the API data.
({
  String city,
  String? state,
})? cityStateForAirNowEmbed({
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
  if (trimmed.isEmpty || trimmed == 'Current location') return null;
  // Reject plain ZIP codes (5-digit or ZIP+4)
  if (RegExp(r'^\d{5}(-\d{4})?$').hasMatch(trimmed)) return null;
  // Match "City, ST" with a 2-letter state abbreviation
  final match = RegExp(r'^(.+?),\s*([A-Za-z]{2})$').firstMatch(trimmed);
  if (match != null) {
    return (
      city: match.group(1)!.trim(),
      state: match.group(2)!.toUpperCase(),
    );
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
  });

  static const String routeName = '/recommendation';

  final AqiService? aqiService;

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  AqiService get _aqiService =>
      widget.aqiService ?? AirNowAqiService();

  RecommendationArgs? _args;
  AqiResult? _aqiResult;
  bool _loading = false;

  Recommendation? _lightRecommendation;
  Recommendation? _moderateRecommendation;
  Recommendation? _vigorousRecommendation;

  String get _location => _args?.location ?? '';

  ({
    Recommendation light,
    Recommendation moderate,
    Recommendation vigorous,
  }) _recommendationsForCategory(
    String category,
    SymptomLevel symptomLevel,
  ) {
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
        setState(() {
          _aqiResult = const AqiFailure(
            message: 'Please use "Use my location" or enter a ZIP code or city on the home screen to see air quality.',
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
    if (args.useCoordinates && args.latitude != null && args.longitude != null) {
      result = await _aqiService.getAqiForCoordinates(
        args.latitude!,
        args.longitude!,
        locationLabel: args.location,
      );
    } else if (args.location.trim().isNotEmpty) {
      result = await _aqiService.getAqiForLocation(args.location);
    } else {
      result = const AqiFailure(
        message: 'No location provided. Use "Use my location" or enter a ZIP or city.',
      );
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
                    child: Icon(Icons.air, color: AppTheme.primaryTeal, size: 28),
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    header: true,
                    child: Text(
                      'Air quality',
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
                        final uri = Uri.parse('https://www.airnow.gov/aqi/aqi-basics/');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Text(
                        'More details',
                        style: TextStyle(
                          color: Colors.blue,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity recommendation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Go back',
          onPressed: () => Navigator.of(context).pop(),
        ),

        actions : [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              if (value == 'about') {
                Navigator.pushNamed(context, '/about');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'about',
                child: Text('About'),
              ),
            ],
          ),
        ],
      ),
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
              ),
              const SizedBox(height: 20),
              _ExplanationCard(
                symptomLevel: symptomLevel,
                aqiColor: _aqiResult is AqiSuccess
                  ? mapAqiCategory((_aqiResult as AqiSuccess).data.category)
                  : null,
              ),
              const SizedBox(height: 20),
              _DisclaimerCard(),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _openNextDayGuidance,
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('View next-day activity guidance'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
  }) Function(String category, SymptomLevel symptomLevel)
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
    if (args.useCoordinates && args.latitude != null && args.longitude != null) {
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
                  'Next-day activity guidance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Forecast-based recommendation for tomorrow.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Semantics(
                      label: 'Loading next-day forecast',
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
                          'Forecast AQI: ${data.aqiValue} (${data.category})',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Location: ${data.locationLabel}',
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
                    );
                  },
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: Icon(Icons.air, color: AppTheme.primaryTeal, size: 28),
                ),
                const SizedBox(width: 10),
                Semantics(
                  header: true,
                  child: Text(
                    'Air quality',
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
                        label: 'Loading air quality',
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Loading air quality…'),
                  ],
                ),
              )
            else if (aqiResult == null)
              Text(
                location.isEmpty
                    ? 'Enter location on home to see AQI'
                    : 'Location: $location',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...switch (aqiResult!) {
                AqiSuccess(data: final data, lastUpdated: final lastUpdated) => [
                  Text(
                    'Location: ${data.locationLabel}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AQI: ${data.aqiValue}  •  ${data.category}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (lastUpdated != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Updated ${_formatTime(lastUpdated)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ],
                AqiFailure(message: final message, lastKnown: final lastKnown) => [
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  if (lastKnown != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Last known: AQI ${lastKnown.aqiValue} (${lastKnown.category})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              },
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day(s) ago';
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    this.symptomLevel,
    this.lightRecommendation,
    this.moderateRecommendation,
    this.vigorousRecommendation,
  });

  final SymptomLevel? symptomLevel;
  final Recommendation? lightRecommendation;
  final Recommendation? moderateRecommendation;
  final Recommendation? vigorousRecommendation;

  /// Dark green / red for icon + text contrast on light backgrounds (not sole indicator).
  static const Color _okGreen = Color(0xFF0D5C2E);
  static const Color _notOkRed = Color(0xFFB71C1C);

  Widget _activityRow(BuildContext context, String label, Recommendation? result) {
    if (result == null) {
      return Text(
        '$label: loading...',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
      );
    }

    final isOk = result == Recommendation.ok;
    final statusText = isOk ? 'Recommended' : 'Not recommended';

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
      color: AppTheme.primaryTeal.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Recommended activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            if (symptomLevel == null)
              Text(
                'Recommendation will appear here once AQI is available.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.45,
                      color: AppTheme.textSecondary,
                    ),
              )
            else
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     _activityRow(context, 'Light activity', lightRecommendation),
              //     const SizedBox(height: 10),
              //     _activityRow(context, 'Medium activity', moderateRecommendation),
              //     const SizedBox(height: 10),
              //     _activityRow(context, 'Vigorous activity', vigorousRecommendation),
              //   ],
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _activityRow(context, 'Light activity', lightRecommendation),
                  const SizedBox(height: 10),
                  _activityRow(context, 'Medium activity', moderateRecommendation),
                  const SizedBox(height: 10),
                  _activityRow(context, 'Vigorous activity', vigorousRecommendation),

                  const SizedBox(height: 16),

                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
                    title: const Text(
                      'Activity examples',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: const [
                      _ActivityExampleSection(
                        title: 'Light activity',
                        examples: [
                          'Walking slowly on level ground',
                          'Sitting in chair, standing',
                          'Using computer',
                          'Writing on paper or black board',
                          'Cooking, eating, drinking',
                          'Playing musical instruments',
                          'Carrying school books',
                        ],
                      ),
                      SizedBox(height: 10),
                      _ActivityExampleSection(
                        title: 'Moderate activity',
                        examples: [
                          'Playing badminton',
                          'Skateboarding',
                          'Aerobic dancing',
                          'Competitive table tennis',
                          'Softball - slow pitch',
                          'Shooting basketballs',
                          'Outdoor carpentry',
                        ],
                      ),
                      SizedBox(height: 10),
                      _ActivityExampleSection(
                        title: 'Vigorous activity',
                        examples: [
                          'Running, jogging',
                          'Performing jumping jacks',
                          'Football, Soccer, Baseball',
                          'Competitive swimming',
                          'Ice hockey, Water polo',
                          'Racquetball, Squash',
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
  });

  final SymptomLevel? symptomLevel;
  final AqiColor? aqiColor;

  String _getExplanation() {
    if (symptomLevel == null || aqiColor == null) {
      return 'Explanation will appear here after you get a recommendation.';
    }

    switch (aqiColor) {
      case AqiColor.green:
        return 'Air quality is good. Most people, even with symptoms, can safely perform outdoor activities';

      case AqiColor.yellow:
        return 'Air quality is acceptable. Sensitive individuals may experience mild symptoms, so consider limited prolonged exertion.';

      case AqiColor.orange:
        return 'Air quality is unhealthy for sensitive groups. Symptoms may worsen, so reduce outdoor activity intensity and duration.';
      
      case AqiColor.red:
        return 'Air quality is unhealthy. It is recommended to avoid strenuous outdoor activities, especially if experiencing symptoms.';

      case AqiColor.purple:
        return 'Air quality is very unhealthy. Outdoor activities should be avoided due to high risk of symptom aggravation.';
    
      default:
        return 'Unable to determine recommendation';
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
                'Why this recommendation',
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
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text(
                    'More information',
                    style: TextStyle(
                      color: Colors.blue,
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
  static const Color _amberBorder = Color(0xFFC67F00);
  static const Color _amberIcon = Color(0xFF8D5B00);
  static const Color _amberBg = Color(0xFFFFF8E6);

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
              child: Icon(Icons.health_and_safety_outlined, color: _amberIcon, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                container: true,
                child: Text(
                  'This app is a guidance tool only and is not a substitute for '
                  'professional medical advice. It does not diagnose asthma or any '
                  'medical condition and does not provide emergency medical guidance.',
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

  const _ActivityExampleSection({
    required this.title,
    required this.examples,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
    );
  }
}
