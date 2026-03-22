import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Web implementation of the AirNow AQI forecast widget via iframe.
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
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType =
        'airnow-aqi-${widget.city}-${widget.state ?? ''}-${widget.dataType ?? ''}-${DateTime.now().microsecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = _buildWidgetUrl()
        ..style.border = 'none'
        ..style.borderRadius = '25px'
        ..style.width = '230px'
        ..style.height = '230px';
      return iframe;
    });
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: SizedBox(
        width: 230,
        height: 230,
        child: HtmlElementView(viewType: _viewType),
      ),
    );
  }
}
