import 'package:flutter/material.dart';

import '../app_theme.dart';

class BottomLogosBar extends StatelessWidget {
  const BottomLogosBar({
    super.key,
    this.riLogoHeight = 68,
    this.soeWordmarkHeight = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  static const String _riLogoPath = 'assets/images/RI_Logo.png';
  static const String _soeWordmarkPath =
      'assets/images/SoE_two color wordmark.png';

  final double riLogoHeight;
  final double soeWordmarkHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: const Border(
            top: BorderSide(color: AppTheme.borderSubtle),
          ),
        ),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Image.asset(
                  _riLogoPath,
                  height: riLogoHeight,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Image.asset(
                  _soeWordmarkPath,
                  height: soeWordmarkHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

