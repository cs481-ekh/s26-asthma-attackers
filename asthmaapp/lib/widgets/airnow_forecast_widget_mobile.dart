import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Mobile/desktop implementation of the AirNow AQI forecast widget.
class AirNowForecastWidget extends StatefulWidget {
  const AirNowForecastWidget({
    super.key,
    required this.city,
    this.state,
    this.country = 'USA',
    this.dataType,
  });

  final String city;
  final String? state;
  final String country;
  final String? dataType;

  @override
  State<AirNowForecastWidget> createState() => _AirNowForecastWidgetState();
}

class _AirNowForecastWidgetState extends State<AirNowForecastWidget> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _hasError = false;
  String? _errorDescription;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      // Use a common browser user-agent to avoid overly strict bot/webview filtering.
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _loading = true;
                _hasError = false;
                _errorDescription = null;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            // Ignore sub-resource failures; only fail when the main document fails.
            if (error.isForMainFrame != true) return;
            if (mounted) {
              setState(() {
                _loading = false;
                _hasError = true;
                _errorDescription = error.description;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_buildWidgetUrl()));
  }

  Future<void> _retryLoad() async {
    setState(() {
      _loading = true;
      _hasError = false;
      _errorDescription = null;
    });
    await _controller.loadRequest(Uri.parse(_buildWidgetUrl()));
  }

  String _buildWidgetUrl() {
    final params = <String, String>{
      'city': widget.city,
      if (widget.state != null && widget.state!.isNotEmpty) 'state': widget.state!,
      'country': widget.country,
      if (widget.dataType != null) 'dataType': widget.dataType!,
    };
    final query = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return 'https://widget.airnow.gov/aq-dial-widget-with-forecast/?$query';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return SizedBox(
        width: 230,
        height: 230,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 28),
              const SizedBox(height: 8),
              const Text(
                'Unable to load AirNow widget.',
                textAlign: TextAlign.center,
              ),
              if (_errorDescription != null) ...[
                const SizedBox(height: 6),
                Text(
                  _errorDescription!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 10),
              TextButton(
                onPressed: _retryLoad,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: SizedBox(
        width: 230,
        height: 230,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
