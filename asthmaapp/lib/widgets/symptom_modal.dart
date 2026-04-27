import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';

/// Symptom level as defined by NIH (project plan 3.1.2).
/// A = No respiratory or asthma symptoms
/// B = Few respiratory or asthma symptoms
/// C = Daily respiratory or asthma symptoms
enum SymptomLevel {
  a(
    'A',
    'No respiratory or asthma symptoms',
    'Child has no breathing issues or asthma symptoms.',
  ),
  b(
    'B',
    'Few respiratory or asthma symptoms',
    'Child has mild or occasional symptoms.',
  ),
  c(
    'C',
    'Daily respiratory or asthma symptoms',
    'Child has symptoms most days or more severe symptoms.',
  );

  const SymptomLevel(this.id, this.label, this.description);
  final String id;
  final String label;
  final String description;
}

extension SymptomLevelLocalization on SymptomLevel {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case SymptomLevel.a:
        return l10n.symptomALabel;
      case SymptomLevel.b:
        return l10n.symptomBLabel;
      case SymptomLevel.c:
        return l10n.symptomCLabel;
    }
  }

  String localizedDescription(AppLocalizations l10n) {
    switch (this) {
      case SymptomLevel.a:
        return l10n.symptomADescription;
      case SymptomLevel.b:
        return l10n.symptomBDescription;
      case SymptomLevel.c:
        return l10n.symptomCDescription;
    }
  }
}

/// Outline for the general symptom popup modal.
/// Presents the three symptom levels with non-technical descriptions
/// so the user can select exactly one before generating a recommendation.
class SymptomModal extends StatelessWidget {
  const SymptomModal({
    super.key,
    this.initialSelection,
    required this.onSelect,
  });

  final SymptomLevel? initialSelection;
  final ValueChanged<SymptomLevel> onSelect;

  /// Shows the symptom selection modal (bottom sheet).
  /// Returns the selected [SymptomLevel] when the user confirms, or null if dismissed.
  static Future<SymptomLevel?> show(
    BuildContext context, {
    SymptomLevel? current,
  }) {
    return showModalBottomSheet<SymptomLevel>(
      context: context,
      isScrollControlled: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SymptomModalContent(
        initialSelection: current,
        onSelect: (level) => Navigator.of(context).pop(level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SymptomModalContent(
      initialSelection: initialSelection,
      onSelect: onSelect,
    );
  }
}

class _SymptomModalContent extends StatefulWidget {
  const _SymptomModalContent({this.initialSelection, required this.onSelect});

  final SymptomLevel? initialSelection;
  final ValueChanged<SymptomLevel> onSelect;

  @override
  State<_SymptomModalContent> createState() => _SymptomModalContentState();
}

class _SymptomModalContentState extends State<_SymptomModalContent> {
  late SymptomLevel? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  l10n.symptomSelectTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.symptomSelectSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: SymptomLevel.values.map((level) {
                    final isSelected = _selected == level;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _selected = level),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.bsuBlue.withValues(alpha: 0.06)
                                  : null,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.bsuBlue
                                    : Colors.black.withValues(alpha: 0.12),
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      level.id,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        level.localizedLabel(l10n),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        size: 22,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  level.localizedDescription(l10n),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => widget.onSelect(_selected!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.bsuOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(l10n.confirmSelection),
              ),
            ],
          ),
        );
      },
    );
  }
}
