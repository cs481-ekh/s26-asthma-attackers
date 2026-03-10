import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/aqi_result.dart';
import '../models/recommendation_args.dart';
import '../services/aqi_service.dart';
import '../services/airnow_aqi_service.dart';
import '../widgets/symptom_modal.dart';
import '../services/slide_rule_service.dart';

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
      result = await _aqiService.getAqiForCoordinates(args.latitude!, args.longitude!);
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
          final aqiColor = mapAqiCategory(result.data.category);

          _lightRecommendation = SlideRuleService.getRecommendation(
            aqiColor: aqiColor,
            activityLevel: ActivityLevel.light,
            symptomLevel: _args!.symptomLevel,
          );

          _moderateRecommendation = SlideRuleService.getRecommendation(
            aqiColor: aqiColor,
            activityLevel: ActivityLevel.moderate,
            symptomLevel: _args!.symptomLevel,
          );

          _vigorousRecommendation = SlideRuleService.getRecommendation(
            aqiColor: aqiColor,
            activityLevel: ActivityLevel.vigorous,
            symptomLevel: _args!.symptomLevel,
          );
        }

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final symptomLevel = _args?.symptomLevel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity recommendation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AqiCard(
                location: _location,
                aqiResult: _aqiResult,
                loading: _loading,
                onRetry: _fetchAqi,
              ),
              const SizedBox(height: 20),
              _RecommendationCard(
                symptomLevel: symptomLevel,
                lightRecommendation: _lightRecommendation,
                moderateRecommendation: _moderateRecommendation,
                vigorousRecommendation: _vigorousRecommendation,
              ),
              const SizedBox(height: 20),
              _ExplanationCard(symptomLevel: symptomLevel),
              const SizedBox(height: 20),
              _DisclaimerCard(),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Open next-day guidance modal or navigate to next-day view
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('View next-day activity guidance'),
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
                Icon(Icons.air, color: AppTheme.primaryTeal, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Air quality',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading air quality…'),
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

  Widget _activityRow(String label, Recommendation? result) {
    if (result == null) {
      return Text("$label: loading...");
    }

    final isOk = result == Recommendation.ok;

    return Row(
      children: [
        Icon(
          isOk ? Icons.check_circle : Icons.cancel,
          color: isOk ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text("$label: ${isOk ? "Recommended" : "Not recommended"}"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const placeholderColor = Color(0xFF4CAF50);
    return Card(
      color: placeholderColor.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended activity',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            // Text(
            //   symptomLevel != null
            //       ? 'Maximum allowable activity will appear here based on AQI and symptom level (${symptomLevel!.id}).'
            //       : 'Recommendation will appear here once AQI is available.',
            //   style: Theme.of(context).textTheme.bodyLarge,
            // ),
            if (symptomLevel == null)
              Text(
                'Recommendation will appear here once AQI is available.',
                style: Theme.of(context).textTheme.bodyLarge,
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _activityRow("Light level activity", lightRecommendation),
                  const SizedBox(height: 6),
                  _activityRow("Moderate level activity", moderateRecommendation),
                  const SizedBox(height: 6),
                  _activityRow("Vigorous level activity", vigorousRecommendation),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({this.symptomLevel});

  final SymptomLevel? symptomLevel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why this recommendation',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              symptomLevel != null
                  ? 'Brief explanation referencing current AQI and symptom level (${symptomLevel!.id}) will appear here.'
                  : 'Explanation will appear here after you get a recommendation.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.amber.shade800, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'This app is a guidance tool only and is not a substitute for '
                'professional medical advice. It does not diagnose asthma or any '
                'medical condition and does not provide emergency medical guidance.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
