import 'package:flutter/material.dart';
import '../app_theme.dart';

class SectionHeaderWithInfo extends StatelessWidget {
  final String title;
  final VoidCallback onInfoPressed;

  const SectionHeaderWithInfo({
    super.key,
    required this.title,
    required this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.info_outline, size: 20),
          onPressed: onInfoPressed,
          tooltip: 'More information',
        ),
      ],
    );
  }
}