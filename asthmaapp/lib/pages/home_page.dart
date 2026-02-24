import 'package:flutter/material.dart';

import '../models/recommendation_args.dart';
import '../pages/recommendation_page.dart';
import '../widgets/symptom_modal.dart';

/// Main entry page: symptom selection and location input.
/// Matches the flow "app launches directly to symptom input" (3.1.1).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SymptomLevel? _symptomLevel;
  final TextEditingController _locationController = TextEditingController();
  final _locationFocus = FocusNode();

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  Future<void> _openSymptomModal() async {
    final selected = await SymptomModal.show(context, current: _symptomLevel);
    if (selected != null && mounted) {
      setState(() => _symptomLevel = selected);
    }
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
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a ZIP code or city to get air quality.'),
        ),
      );
      return;
    }
    Navigator.of(context).pushNamed(
      RecommendationPage.routeName,
      arguments: RecommendationArgs(
        symptomLevel: _symptomLevel!,
        location: location,
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
              // Symptom selection card
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
              // Location / AQI input card
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
                      Text(
                        'ZIP code or city (web). On mobile, location can be used automatically.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _locationController,
                        focusNode: _locationFocus,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 83702 or Boise',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _getRecommendation(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _symptomLevel == null ? null : _getRecommendation,
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
