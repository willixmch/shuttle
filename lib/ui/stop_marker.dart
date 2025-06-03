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
    final stopMarker = selected ? 'lib/assets/stop_marker_selected.svg' : 'lib/assets/stop_marker_unselected.svg';

    return SvgPicture.asset(
      stopMarker,
    );
  }
}