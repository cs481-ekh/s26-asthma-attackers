import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/recommendation_args.dart';
import '../widgets/symptom_modal.dart';

/// Displays activity recommendation based on symptom level and AQI.
/// Layout includes: AQI display, color-coded guidance, explanation, disclaimer (3.1.5, 3.1.6).
class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  static const String routeName = '/recommendation';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final symptomLevel = args is RecommendationArgs ? args.symptomLevel : null;
    final location = args is RecommendationArgs ? args.location : '';

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
              // AQI display area (stub: real AQI integration later)
              _AqiCard(location: location),
              const SizedBox(height: 20),
              // Recommendation card (color-coded placeholder)
              _RecommendationCard(symptomLevel: symptomLevel),
              const SizedBox(height: 20),
              // Explanation area
              _ExplanationCard(symptomLevel: symptomLevel),
              const SizedBox(height: 20),
              // Disclaimer (3.1.6)
              _DisclaimerCard(),
              const SizedBox(height: 16),
              // Next-day guidance outline (3.1.4)
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
  const _AqiCard({required this.location});

  final String location;

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
            // Placeholder for AQI value and category
            Text(
              location.isEmpty ? 'Enter location on home to see AQI' : 'Location: $location',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'AQI: —  •  Category: —',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({this.symptomLevel});

  final SymptomLevel? symptomLevel;

  @override
  Widget build(BuildContext context) {
    // Placeholder color; real logic will drive color and text (3.1.5).
    const placeholderColor = Color(0xFF4CAF50); // green placeholder
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
            Text(
              symptomLevel != null
                  ? 'Maximum allowable activity will appear here based on AQI and symptom level (${symptomLevel!.id}).'
                  : 'Recommendation will appear here once AQI is available.',
              style: Theme.of(context).textTheme.bodyLarge,
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
