import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:math' show pi;

class StopMarker extends StatefulWidget {
  final Uint8List iconBytes;
  final VoidCallback? onTap;
  final ValueNotifier<double> rotationNotifier;

  const StopMarker({
    super.key,
    required this.iconBytes,
    this.onTap,
    required this.rotationNotifier,
  });

  @override
  StopMarkerState createState() => StopMarkerState();
}

class StopMarkerState extends State<StopMarker> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.rotationNotifier,
      builder: (context, rotation, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Transform.rotate(
            angle: -rotation * (pi / 180), // Inverse rotation in radians
            child: Image.memory(widget.iconBytes),
          ),
        );
      },
    );
  }
}