import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shuttle/services/location_service.dart';
import 'package:shuttle/services/map_tile_cache.dart';

class LeafletMap extends StatefulWidget {
  final bool isDraggingPanel;
  final Position? userPosition;

  const LeafletMap({
    super.key,
    required this.isDraggingPanel,
    this.userPosition,
  });

  @override
  LeafletMapState createState() => LeafletMapState();
}

class LeafletMapState extends State<LeafletMap> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController;
  Stream<Position>? _positionStream;
  LatLng? _currentLocation;
  static const double _userZoomLevel = 18.0;
  bool _showLocateMeFab = true; // Show FAB by default
  late final ValueNotifier<double> _rotationNotifier;
  CachedTileProvider? _tileProvider;
  late final Future<void> _tileProviderFuture;

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(
      mapController: MapController(),
      vsync: this,
    );
    _rotationNotifier = ValueNotifier<double>(0.0);

    // Initialize tile caching and store the future
    _tileProviderFuture = MapTileCache.initializeTileCaching().then((provider) {
      _tileProvider = provider;
    });

    _startLocationUpdates();

    _mapController.mapController.mapEventStream.listen((event) {
      if (event is MapEventMove || event is MapEventMoveEnd) {
        setState(() {
          _showLocateMeFab = true; // Show FAB when map is moved
        });
      }
      if (event is MapEventRotate || event is MapEventRotateEnd) {
        _rotationNotifier.value = _mapController.mapController.camera.rotation;
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.drain();
    _rotationNotifier.dispose();
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
        }
      });
    }
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
        _showLocateMeFab = false; // Hide FAB after recentering
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double screenHeight = MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top;

    return FutureBuilder<void>(
      future: _tileProviderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || _tileProvider == null) {
          return const Center(child: CircularProgressIndicator());
        }

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
                  tileProvider: _tileProvider!, // Use cached tile provider
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
            Positioned(
              right: 16.0,
              bottom: screenHeight * 0.32,
              child: AnimatedOpacity(
                opacity: _showLocateMeFab ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: FloatingActionButton.small(
                  onPressed: _recenterMap,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  backgroundColor: colorScheme.secondaryContainer,
                  child: const Icon(Icons.near_me),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}