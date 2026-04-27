import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/sdp_sticker.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/bottom_logos_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.localeNotifier});

  final ValueNotifier<Locale?> localeNotifier;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget sectionBody(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        height: 1.5,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget link(
    BuildContext context, {
    required String label,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.linkColor,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      bottomNavigationBar: const BottomLogosBar(
        riLogoHeight: 104,
        soeWordmarkHeight: 72,
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: l10n.goBack,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.aboutTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Overview
            sectionTitle(context, l10n.appName),
            sectionBody(context, l10n.aboutOverviewBody),

            // Objective
            sectionTitle(context, l10n.aboutObjectiveTitle),
            sectionBody(context, l10n.aboutObjectiveBody),

            // How it works
            sectionTitle(context, l10n.aboutHowItWorksTitle),
            sectionBody(context, l10n.aboutHowItWorksBody),

            // Inputs
            sectionTitle(context, l10n.aboutInputsTitle),
            sectionBody(context, l10n.aboutInputsBody),

            // Output
            sectionTitle(context, l10n.aboutOutputTitle),
            sectionBody(context, l10n.aboutOutputBody),

            sectionTitle(context, l10n.aboutAirQualityRisksTitle),
            sectionBody(context, l10n.aboutAirQualityRisksBody),

            // Resources
            sectionTitle(context, l10n.aboutResourcesTitle),
            const SizedBox(height: 8),

            link(
              context,
              label: l10n.aboutResourceAirNow,
              url: "https://www.airnow.gov/?city=Boise&state=ID&country=USA",
            ),

            const SizedBox(height: 8),

            link(
              context,
              label: l10n.aboutResourceBsuAirQuality,
              url:
                  "https://www.boisestate.edu/research-resilience/resources-hazards/air-quality-and-smoke/",
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            // Contact
            // Contact Us
            sectionTitle(context, l10n.aboutContactTitle),
            sectionBody(context, l10n.aboutContactBody),

            const SizedBox(height: 8),

            link(
              context,
              label: l10n.aboutResourceBsuResilienceInstitute,
              url: "https://www.boisestate.edu/research-resilience/",
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            Center(child: SdpFooterSticker()),
          ],
        ),
      ),
    );
  }
}
