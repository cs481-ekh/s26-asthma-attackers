import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SdpFooterSticker extends StatelessWidget {
  const SdpFooterSticker({super.key});

  Future<void> _launchURL() async {
    final uri = Uri.parse(
      "https://www.boisestate.edu/coen-cs/community/cs481-senior-design-project/",
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🖼 Sticker
        Image.asset('assets/images/bsu-sdp-button.png', width: 150),

        const SizedBox(height: 12),

        // 📄 Attribution text (always visible)
        const Text(
          "This website/app was created for a",
          textAlign: TextAlign.center,
        ),
        const Text(
          "Boise State University",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text(
          "Computer Science Senior Design Project by",
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 10),

        const Text("Lauren Nutting", textAlign: TextAlign.center),
        const Text("John Patrick", textAlign: TextAlign.center),
        const Text("Cameron Quitugua", textAlign: TextAlign.center),
        const Text("Hailey Revel-Whitaker", textAlign: TextAlign.center),

        const SizedBox(height: 10),

        const Text(
          "For information about sponsoring a project go to",
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        GestureDetector(
          onTap: _launchURL,
          child: const Text(
            "https://www.boisestate.edu/coen-cs/community/cs481-senior-design-project/",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD64309),
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
