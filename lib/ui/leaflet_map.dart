import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shuttle/services/map_tile_cache.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/ui/stop_marker.dart';

class LeafletMap extends StatefulWidget {
  final bool isDraggingPanel;
  final Estate? selectedEstate;
  final Stop? selectedStop;
  final bool hasLocationPermission;
  final LatLng? currentLocation;
  final bool isLocationReady;
  final ValueChanged<Stop>? onStopSelected;

  const LeafletMap({
    super.key,
    required this.isDraggingPanel,
    this.selectedEstate,
    this.selectedStop,
    required this.hasLocationPermission,
    this.currentLocation,
    required this.isLocationReady,
    this.onStopSelected,
  });

  @override
  LeafletMapState createState() => LeafletMapState();
}

class LeafletMapState extends State<LeafletMap> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController;
  bool _showLocateMeFab = true;
  CachedTileProvider? _tileProvider;
  late final Future<void> _tileProviderFuture;
  List<Stop> _stops = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Stream<Position>? _positionStream;
  bool _isStreamStarted = false;

  @override
  void initState() {
    super.initState();
    _mapController = AnimatedMapController(
      mapController: MapController(),
      vsync: this,
    );

    _tileProviderFuture = MapTileCache.initializeTileCaching().then((provider) {
      _tileProvider = provider;
    });

    _fetchStops();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animateToInitialPosition();
        _startLocationStream();
      }
    });

    _mapController.mapController.mapEventStream.listen((event) {
      if ((event is MapEventMove || event is MapEventMoveEnd) &&
          (event.source == MapEventSource.onDrag ||
              event.source == MapEventSource.multiFingerGestureStart ||
              event.source == MapEventSource.multiFingerEnd ||
              event.source == MapEventSource.scrollWheel)) {
        setState(() {
          _showLocateMeFab = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(LeafletMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedEstate?.estateId != widget.selectedEstate?.estateId ||
        oldWidget.selectedStop?.stopId != widget.selectedStop?.stopId) {
      _fetchStops();
      if (widget.selectedStop != null &&
          widget.selectedStop!.stopId != oldWidget.selectedStop?.stopId) {
        _mapController.animateTo(
          dest: LatLng(widget.selectedStop!.latitude, widget.selectedStop!.longitude),
          zoom: _userZoomLevel,
          offset: const Offset(0, -80),
          duration: const Duration(milliseconds: 500),
        );
      }
    }
    if (widget.hasLocationPermission != oldWidget.hasLocationPermission ||
        widget.isLocationReady != oldWidget.isLocationReady) {
      _startLocationStream();
    }
  }

  @override
  void dispose() {
    _positionStream?.drain();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchStops() async {
    if (widget.selectedEstate != null) {
      final stops = await _dbHelper.getBoardingStopsForEstate(widget.selectedEstate!.estateId);
      if (mounted) {
        setState(() {
          _stops = stops;
        });
      }
    } else {
      setState(() {
        _stops = [];
      });
    }
  }

  void _animateToInitialPosition() {
    if (widget.selectedStop != null) {
      _mapController.animateTo(
        dest: LatLng(widget.selectedStop!.latitude, widget.selectedStop!.longitude),
        zoom: _userZoomLevel,
        offset: const Offset(0, -80),
        duration: const Duration(milliseconds: 500),
      );
      _showLocateMeFab = false;
    } else if (widget.isLocationReady && widget.currentLocation != null) {
      _mapController.animateTo(
        dest: widget.currentLocation!,
        zoom: _userZoomLevel,
        offset: const Offset(0, -80),
        duration: const Duration(milliseconds: 500),
      );
      _showLocateMeFab = false;
    }
  }

  void _startLocationStream() {
    if (!widget.isLocationReady || _isStreamStarted) {
      setState(() {
        _isStreamStarted = false;
        _positionStream = null;
      });
      return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
    setState(() {
      _isStreamStarted = true;
    });
  }

  void _recenterMap() {
    if (widget.currentLocation != null && widget.isLocationReady) {
      _mapController.animateTo(
        dest: widget.currentLocation!,
        zoom: _userZoomLevel,
        offset: const Offset(0, -80),
        duration: const Duration(milliseconds: 500),
      );
      setState(() {
        _showLocateMeFab = false;
      });
    } else if (widget.selectedStop != null) {
      _mapController.animateTo(
        dest: LatLng(widget.selectedStop!.latitude, widget.selectedStop!.longitude),
        zoom: _userZoomLevel,
        offset: const Offset(0, -80),
        duration: const Duration(milliseconds: 500),
      );
      setState(() {
        _showLocateMeFab = false;
      });
    }
  }

  static const double _userZoomLevel = 17.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double screenHeight = MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top;
    final double stopMarkerSize = 48;

    final initialCenter = widget.selectedStop != null
        ? LatLng(widget.selectedStop!.latitude, widget.selectedStop!.longitude)
        : widget.currentLocation != null && widget.isLocationReady
            ? widget.currentLocation!
            : const LatLng(22.3964, 114.1095);
    final initialZoom = widget.selectedStop != null || widget.isLocationReady
        ? _userZoomLevel
        : 12.0;

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
                initialCenter: initialCenter,
                initialZoom: initialZoom,
                maxZoom: 19.0,
                minZoom: 3.0,
                interactionOptions: widget.isDraggingPanel
                    ? const InteractionOptions(flags: InteractiveFlag.none)
                    : const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: ['abcd'],
                  maxZoom: 19,
                  retinaMode: RetinaMode.isHighDensity(context),
                  tileProvider: _tileProvider!,
                ),
                if (_isStreamStarted && widget.isLocationReady)
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
                MarkerLayer(
                  markers: _stops.map((stop) {
                    return Marker(
                      alignment: Alignment.topCenter,
                      point: LatLng(stop.latitude, stop.longitude),
                      child: GestureDetector(
                        onTap: () {
                          _mapController.animateTo(
                            dest: LatLng(stop.latitude, stop.longitude),
                            zoom: _userZoomLevel,
                            offset: const Offset(0, -80),
                            duration: const Duration(milliseconds: 500),
                          );
                          widget.onStopSelected?.call(stop);
                        },
                        child: StopMarker(
                          selected: widget.selectedStop?.stopId == stop.stopId,
                        ),
                      ),
                      width: stopMarkerSize,
                      height: stopMarkerSize,
                    );
                  }).toList(),
                ),
              ],
            ),
            Positioned(
              right: 16.0,
              bottom: screenHeight * 0.48,
              child: AnimatedOpacity(
                opacity: widget.hasLocationPermission && _showLocateMeFab ? 1.0 : 0.0,
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