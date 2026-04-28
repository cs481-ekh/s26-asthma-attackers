import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_theme.dart';

class BottomLogosBar extends StatelessWidget {
  const BottomLogosBar({
    super.key,
    this.riLogoHeight = 68,
    this.soeWordmarkHeight = 48,
    this.spphLogoHeight = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  static const String _riLogoPath = 'assets/images/RI_Logo.png';
  static const String _soeWordmarkPath =
      'assets/images/SoE_two color wordmark.png';
  static const String _spphLogoPath = 'assets/images/BSU_SPPH_Logo.png';

  final double riLogoHeight;
  final double soeWordmarkHeight;

  /// Boise State School of Public and Population Health (wide mark).
  final double spphLogoHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // `Center` inside loose vertical constraints (e.g. Scaffold bottom bar) can
    // expand and steal the full screen — bound each slot with an explicit height.
    final barHeight = math.max(
      riLogoHeight,
      math.max(soeWordmarkHeight, spphLogoHeight),
    );
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: const Border(top: BorderSide(color: AppTheme.borderSubtle)),
        ),
        child: Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: barHeight,
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      _riLogoPath,
                      height: riLogoHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: barHeight,
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      _soeWordmarkPath,
                      height: soeWordmarkHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: barHeight,
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      _spphLogoPath,
                      height: spphLogoHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
