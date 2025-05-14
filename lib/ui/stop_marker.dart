import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StopMarkerWidget extends StatelessWidget {
  final bool selected;

  const StopMarkerWidget({
    super.key,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final markerColor = selected ? colorScheme.primary : colorScheme.outline;

    return SizedBox(
      width: 32, // Adjust size as needed
      height: 32,
      child: SvgPicture.asset(
        'lib/assets/stop_marker.svg',
        width: 32,
        height: 32,
        // If the SVG supports color replacement
        colorFilter: ColorFilter.mode(markerColor, BlendMode.srcIn),
      ),
    );
  }
}