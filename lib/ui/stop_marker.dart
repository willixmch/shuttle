import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StopMarker extends StatelessWidget {
  final bool selected;

  const StopMarker({
    super.key,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final markerColor = selected ? colorScheme.primary : colorScheme.outline;

    return SvgPicture.asset(
      'lib/assets/stop_marker.svg',
      // If the SVG supports color replacement
      colorFilter: ColorFilter.mode(markerColor, BlendMode.srcIn),
    );
  }
}