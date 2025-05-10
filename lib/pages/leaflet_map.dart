import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shuttle/services/location_service.dart';

class LeafletMap extends StatefulWidget {
  final bool isDraggingPanel;
  final Position? userPosition;

  const LeafletMap({
    super.key,
    required this.isDraggingPanel,
    this.userPosition,
  });

  @override
  _LeafletMapState createState() => _LeafletMapState();
}

class _LeafletMapState extends State<LeafletMap> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController;
  Stream<Position>? _positionStream;
  LatLng? _currentLocation;
  static const double _userZoomLevel = 17.0;
  bool _isMapCentered = true; // Tracks if map is centered on user
  final double _fabBottomPadding = 0.24;

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(
      mapController: MapController(),
      vsync: this,
    );
    _startLocationUpdates();
    // Listen to map movements to detect when map is no longer centered
    _mapController.mapController.mapEventStream.listen((event) {
      if (event is MapEventMove || event is MapEventMoveEnd) {
        _checkIfMapCentered();
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.drain();
    _mapController.dispose();
    super.dispose();
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

          // Center map on user location when first detected
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

  // Check if the map's center is close to the user's current location
  void _checkIfMapCentered() {
    if (_currentLocation == null) {
      setState(() {
        _isMapCentered = false;
      });
      return;
    }

    final mapCenter = _mapController.mapController.camera.center;
    const double threshold = 0.0001; // Small threshold for lat/lng difference
    final isCentered = (mapCenter.latitude - _currentLocation!.latitude).abs() < threshold &&
        (mapCenter.longitude - _currentLocation!.longitude).abs() < threshold;

    setState(() {
      _isMapCentered = isCentered;
    });
  }

  // Recenter map to user's current location with smooth animation
  void _recenterMap() {
    if (_currentLocation != null) {
      _mapController.animateTo(
        dest: _currentLocation!,
        zoom: _userZoomLevel,
        rotation: 0,
        duration: const Duration(milliseconds: 1000), // 1-second animation
      );
      setState(() {
        _isMapCentered = true;
      });
    }
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
                : LatLng(37.7749, -122.4194), // Fallback Location
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
          ],
        ),
        // FAB for recentering with fade animation
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