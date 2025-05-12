import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shuttle/services/location_service.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/models/stop.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

// Custom marker widget that dynamically adjusts rotation
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
  _StopMarkerState createState() => _StopMarkerState();
}

class _StopMarkerState extends State<StopMarker> {
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

class LeafletMap extends StatefulWidget {
  final bool isDraggingPanel;
  final Position? userPosition;
  final Estate? selectedEstate;
  final Stop? selectedStop;
  final Function(Stop)? onStopSelected;

  const LeafletMap({
    super.key,
    required this.isDraggingPanel,
    this.userPosition,
    this.selectedEstate,
    this.selectedStop,
    this.onStopSelected,
  });

  @override
  _LeafletMapState createState() => _LeafletMapState();
}

class _LeafletMapState extends State<LeafletMap> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController;
  Stream<Position>? _positionStream;
  LatLng? _currentLocation;
  static const double _userZoomLevel = 18.0;
  bool _isUserCentered = false; // Initialize as false to show FAB initially
  List<Stop> _estateStops = [];
  List<Marker> _cachedMarkers = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static final Map<Color, Uint8List> _iconCache = {};
  late final ValueNotifier<double> _rotationNotifier;

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(
      mapController: MapController(),
      vsync: this,
    );
    _rotationNotifier = ValueNotifier<double>(0.0);
    _startLocationUpdates();
    _loadEstateStops();
    // Animate to selectedStop if available
    if (widget.selectedStop != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.animateTo(
          dest: LatLng(widget.selectedStop!.latitude, widget.selectedStop!.longitude),
          zoom: _userZoomLevel,
          duration: const Duration(milliseconds: 500),
        );
        _checkIfUserCentered(); // Check centering after animation
      });
    }
    _mapController.mapController.mapEventStream.listen((event) {
      if (event is MapEventMove || event is MapEventMoveEnd) {
        _checkIfUserCentered();
      }
      if (event is MapEventRotate || event is MapEventRotateEnd) {
        _rotationNotifier.value = _mapController.mapController.camera.rotation;
      }
    });
  }

  @override
  void didUpdateWidget(LeafletMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedEstate != widget.selectedEstate ||
        oldWidget.selectedStop != widget.selectedStop) {
      _loadEstateStops();
      // Animate to new selectedStop if it changes
      if (widget.selectedStop != null &&
          (oldWidget.selectedStop?.stopId != widget.selectedStop!.stopId ||
              oldWidget.selectedStop?.routeId != widget.selectedStop!.routeId)) {
        _mapController.animateTo(
          dest: LatLng(widget.selectedStop!.latitude, widget.selectedStop!.longitude),
          zoom: _userZoomLevel,
          duration: const Duration(milliseconds: 500),
        );
        _checkIfUserCentered(); // Check centering after animation
      }
    }
  }

  @override
  void dispose() {
    _positionStream?.drain();
    _rotationNotifier.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadEstateStops() async {
    if (widget.selectedEstate != null) {
      final stops = await _dbHelper.getStopsForEstate(widget.selectedEstate!.estateId);
      if (mounted) {
        setState(() {
          _estateStops = stops;
          _cachedMarkers = []; // Trigger marker rebuild
        });
        // Build markers after state update to ensure context is valid
        final markers = await _buildStopMarkers();
        if (mounted) {
          setState(() {
            _cachedMarkers = markers;
          });
        }
      }
    } else {
      setState(() {
        _estateStops = [];
        _cachedMarkers = [];
      });
    }
  }

  void _startLocationUpdates() async {
    if (await LocationService().checkLocationPermissions()) {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );

      _positionStream!.listen((Position position) {
        if (mounted) {
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
          });

          // Only animate to user location if no selectedStop and map is centered on user
          if (_currentLocation != null && _isUserCentered && widget.selectedStop == null) {
            _mapController.animateTo(
              dest: _currentLocation!,
              zoom: _userZoomLevel,
              duration: const Duration(milliseconds: 500),
            );
          }

          _checkIfUserCentered();
        }
      });
    }
  }

  void _checkIfUserCentered() {
    if (_currentLocation == null) {
      setState(() {
        _isUserCentered = false;
      });
      return;
    }

    final mapCenter = _mapController.mapController.camera.center;
    const double threshold = 0.0001;
    final isCentered = (mapCenter.latitude - _currentLocation!.latitude).abs() < threshold &&
        (mapCenter.longitude - _currentLocation!.longitude).abs() < threshold;

    setState(() {
      _isUserCentered = isCentered;
    });
  }

  void _recenterMap() {
    if (_currentLocation != null) {
      _mapController.animateTo(
        dest: _currentLocation!,
        zoom: _userZoomLevel,
        rotation: 0,
        duration: const Duration(milliseconds: 1000),
      );
      setState(() {
        _isUserCentered = true;
      });
    }
  }

  Future<Marker> _buildMarker(Stop stop, bool isSelected) async {
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
            if (widget.onStopSelected != null) {
              widget.onStopSelected!(stop);
            }
          },
          rotationNotifier: _rotationNotifier,
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
          if (widget.onStopSelected != null) {
            widget.onStopSelected!(stop);
          }
        },
        rotationNotifier: _rotationNotifier,
      ),
    );
  }

  Future<List<Marker>> _buildStopMarkers() async {
    List<Marker> markers = [];
    for (var stop in _estateStops) {
      final isSelected = widget.selectedStop != null &&
          stop.stopId == widget.selectedStop!.stopId &&
          stop.routeId == widget.selectedStop!.routeId;
      final marker = await _buildMarker(stop, isSelected);
      markers.add(marker);
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double screenHeight = MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController.mapController,
          options: MapOptions(
            initialCenter: LatLng(37.7749, -122.4194), // Default fallback
            initialZoom: 12.0, // Default fallback zoom
            maxZoom: 19.0,
            minZoom: 3.0,
            interactionOptions: widget.isDraggingPanel
                ? const InteractionOptions(flags: InteractiveFlag.none)
                : const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              subdomains: ['abcd'],
              maxZoom: 19,
              retinaMode: RetinaMode.isHighDensity(context),
            ),
            CurrentLocationLayer(
              positionStream: _positionStream?.map(
                (position) => LocationMarkerPosition(
                  latitude: position.latitude,
                  longitude: position.longitude,
                  accuracy: position.accuracy,
                ),
              ),
              style: const LocationMarkerStyle(
                markerSize: Size(20, 20),
              ),
            ),
            MarkerLayer(markers: _cachedMarkers),
          ],
        ),
        Positioned(
          right: 16.0,
          bottom: screenHeight * 0.32,
          child: AnimatedOpacity(
            opacity: !_isUserCentered && _currentLocation != null ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton.small(
              onPressed: _recenterMap,
              child: const Icon(Icons.near_me),
              foregroundColor: colorScheme.onSecondaryContainer,
              backgroundColor: colorScheme.secondaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}