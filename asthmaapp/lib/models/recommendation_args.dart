import '../widgets/symptom_modal.dart';

/// Arguments passed from home to recommendation page.
class RecommendationArgs {
  const RecommendationArgs({
    required this.symptomLevel,
    required this.location,
  });
  final SymptomLevel symptomLevel;
  final String location;
}
