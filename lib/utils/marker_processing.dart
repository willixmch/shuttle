import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:shuttle/ui/stop_marker.dart';
import 'package:shuttle/models/stop.dart';

class MarkerProcessing {
  static final Map<Color, Uint8List> _iconCache = {};

  static Future<Marker> buildMarker({
    required BuildContext context,
    required Stop stop,
    required bool isSelected,
    required ValueNotifier<double> rotationNotifier,
    required Function(Stop)? onStopSelected,
  }) async {
    final icon = Icons.pin_drop;
    final color = isSelected
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.onSurfaceVariant;
    const size = 40.0;

    // Check icon cache
    if (_iconCache.containsKey(color)) {
      return Marker(
        point: LatLng(stop.latitude, stop.longitude),
        width: size,
        height: size,
        rotate: false,
        child: StopMarker(
          iconBytes: _iconCache[color]!,
          onTap: () {
            if (onStopSelected != null) {
              onStopSelected(stop);
            }
          },
          rotationNotifier: rotationNotifier,
        ),
      );
    }

    // Render icon to bitmap
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final iconData = IconData(icon.codePoint, fontFamily: icon.fontFamily);
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontFamily: iconData.fontFamily,
          fontSize: size,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(canvas, Offset.zero);
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw Exception('Failed to render marker icon');
    final uint8List = bytes.buffer.asUint8List();

    // Cache the icon
    _iconCache[color] = uint8List;

    return Marker(
      point: LatLng(stop.latitude, stop.longitude),
      width: size,
      height: size,
      rotate: false,
      child: StopMarker(
        iconBytes: uint8List,
        onTap: () {
          if (onStopSelected != null) {
            onStopSelected(stop);
          }
        },
        rotationNotifier: rotationNotifier,
      ),
    );
  }
}