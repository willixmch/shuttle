import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shuttle/services/location_service.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/models/stop.dart';
import 'dart:ui' as ui;

class LeafletMap extends StatefulWidget {
  final bool isDraggingPanel;
  final Position? userPosition;
  final Estate? selectedEstate;
  final Stop? selectedStop;

  const LeafletMap({
    super.key,
    required this.isDraggingPanel,
    this.userPosition,
    this.selectedEstate,
    this.selectedStop,
  });

  @override
  _LeafletMapState createState() => _LeafletMapState();
}

class _LeafletMapState extends State<LeafletMap> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController;
  Stream<Position>? _positionStream;
  LatLng? _currentLocation;
  static const double _userZoomLevel = 17.0;
  bool _isMapCentered = true;
  final double _fabBottomPadding = 0.24;
  List<Stop> _estateStops = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(
      mapController: MapController(),
      vsync: this,
    );
    _startLocationUpdates();
    _loadEstateStops();
    _mapController.mapController.mapEventStream.listen((event) {
      if (event is MapEventMove || event is MapEventMoveEnd) {
        _checkIfMapCentered();
      }
    });
  }

  @override
  void didUpdateWidget(LeafletMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedEstate != widget.selectedEstate ||
        oldWidget.selectedStop != widget.selectedStop) {
      _loadEstateStops();
    }
  }

  @override
  void dispose() {
    _positionStream?.drain();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadEstateStops() async {
    if (widget.selectedEstate != null) {
      final stops = await _dbHelper.getStopsForEstate(widget.selectedEstate!.estateId);
      if (mounted) {
        setState(() {
          _estateStops = stops;
        });
      }
    } else {
      setState(() {
        _estateStops = [];
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

          if (_currentLocation != null && _isMapCentered) {
            _mapController.animateTo(
              dest: _currentLocation!,
              zoom: _userZoomLevel,
              duration: const Duration(milliseconds: 500),
            );
          }

          _checkIfMapCentered();
        }
      });
    }
  }

  void _checkIfMapCentered() {
    if (_currentLocation == null) {
      setState(() {
        _isMapCentered = false;
      });
      return;
    }

    final mapCenter = _mapController.mapController.camera.center;
    const double threshold = 0.0001;
    final isCentered = (mapCenter.latitude - _currentLocation!.latitude).abs() < threshold &&
        (mapCenter.longitude - _currentLocation!.longitude).abs() < threshold;

    setState(() {
      _isMapCentered = isCentered;
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
        _isMapCentered = true;
      });
    }
  }

  // Creates a marker icon from a Material Icon
  Future<Marker> _buildMarker(Stop stop, bool isSelected) async {
    final icon = Icons.flag;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    const size = 48.0;

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
    final uint8List = bytes!.buffer.asUint8List();

    return Marker(
      point: LatLng(stop.latitude, stop.longitude),
      width: size,
      height: size,
      child: Image.memory(uint8List),
    );
  }

  // Builds list of markers for all stops
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
    final double screenHeight = MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController.mapController,
          options: MapOptions(
            initialCenter: widget.userPosition != null
                ? LatLng(widget.userPosition!.latitude, widget.userPosition!.longitude)
                : LatLng(37.7749, -122.4194),
            initialZoom: widget.userPosition != null ? _userZoomLevel : 12.0,
            maxZoom: 19.0,
            minZoom: 3.0,
            interactionOptions: widget.isDraggingPanel
                ? const InteractionOptions(flags: InteractiveFlag.none)
                : const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              maxZoom: 19,
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
            FutureBuilder<List<Marker>>(
              future: _buildStopMarkers(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return MarkerLayer(markers: snapshot.data!);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        Positioned(
          right: 16.0,
          bottom: screenHeight * _fabBottomPadding,
          child: AnimatedOpacity(
            opacity: !_isMapCentered && _currentLocation != null ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton(
              onPressed: _recenterMap,
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.near_me,
                color: Color.fromRGBO(44, 149, 225, 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}