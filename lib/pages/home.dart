import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shuttle/ui/estate_filter_sheet.dart';
import 'package:shuttle/ui/home_bar.dart';
import 'package:shuttle/ui/sliding_schedule_panel.dart';
import 'package:shuttle/ui/stop_filter_sheet.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/pages/leaflet_map.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/utils/day_type_checker.dart';
import 'package:shuttle/services/location_service.dart';
import 'package:shuttle/services/route_query.dart';
import 'package:shuttle/services/persistence_estate.dart';
import 'package:shuttle/utils/eta_refresh_timer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final PersistenceEstate _persistneceEstate = PersistenceEstate();
  final LocationService _locationService = LocationService();
  final RouteQuery _routeQuery;
  late final EtaRefreshTimer _etaRefreshTimer;
  List<Map<String, dynamic>> _cachedRouteData = [];
  late ValueNotifier<List<Map<String, dynamic>>> _etaNotifier;
  Estate? _selectedEstate;
  Stop? _selectedStop;
  int? _expandedCardIndex;
  Position? _userPosition;

  final PanelController _panelController = PanelController();
  final double _minHeightFraction = 0.28;
  final double _maxHeightFraction = 1.0;
  final double _overlapAmount = 20.0;
  bool _isDraggingPanel = false;

  HomeState() : _routeQuery = RouteQuery(DatabaseHelper.instance);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _panelController.open();
    });
    DayTypeChecker.initialize();
    _etaNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _etaRefreshTimer = EtaRefreshTimer(
      onUpdate: (updatedRouteData) {
        if (mounted) {
          setState(() {
            _cachedRouteData = updatedRouteData;
            _etaNotifier.value = updatedRouteData;
          });
        }
      },
      getRouteData: () => _cachedRouteData,
      getEffectiveStop: () => _selectedStop,
    );
    _loadSchedule();
  }

  @override
  void dispose() {
    _etaRefreshTimer.dispose();
    _etaNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    final persistenceEstate = await _persistneceEstate.estateQuery();
    if (mounted && persistenceEstate['estate'] != null) {
      setState(() {
        _selectedEstate = persistenceEstate['estate'];
      });
    }

    _userPosition = await _locationService.getCurrentPosition();

    if (_selectedStop == null) {
      if (_userPosition != null && _selectedEstate != null) {
        _selectedStop = await _locationService.findClosestStop(
          _userPosition!,
          _selectedEstate!.estateId,
          _dbHelper,
        );
      }
      if (_selectedStop == null && _selectedEstate != null) {
        final stops = await _dbHelper.getStopsForEstate(
          _selectedEstate!.estateId,
        );
        if (stops.isNotEmpty) {
          _selectedStop = stops.first;
        }
      }
    }

    final routeData = await _routeQuery.loadRouteData(
      selectedEstate: _selectedEstate,
      selectedStop: _selectedStop,
    );

    if (mounted) {
      setState(() {
        _cachedRouteData = routeData;
        _etaNotifier.value = routeData;
      });
      _etaRefreshTimer.startRefreshTimer();
    }
  }

  void _showEstateFilterSheet() {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EstateFilterSheet(
          onEstateSelected: (Estate estate) async {
            await _persistneceEstate.saveEstate(estate);
            setState(() {
              _selectedEstate = estate;
              _selectedStop = null;
              _expandedCardIndex = null;
            });
            await _loadSchedule();
          },
        );
      },
    );
  }

  void _showStopFilterSheet() {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StopFilterSheet(
          estateId: _selectedEstate?.estateId ?? '',
          onStopSelected: (Stop stop) async {
            setState(() {
              _selectedStop = stop;
              _expandedCardIndex = null;
            });
            await _loadSchedule();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top;
    final double minHeight = screenHeight * _minHeightFraction;
    final double maxHeight = screenHeight * _maxHeightFraction + _overlapAmount;

    return Scaffold(
      body: Stack(
        children: [
          SlidingUpPanel(
            controller: _panelController,
            minHeight: minHeight,
            maxHeight: maxHeight,
            snapPoint: null,
            panelBuilder:
                (scrollController) => SlidingSchedulePanel(
                  scrollController: scrollController,
                  overlapAmount: _overlapAmount,
                  routeData: _cachedRouteData,
                  etaNotifier: _etaNotifier,
                  expandedCardIndex: _expandedCardIndex,
                  onToggleCard: (index) {
                    setState(() {
                      if (_expandedCardIndex == index) {
                        _expandedCardIndex = null;
                      } else {
                        _expandedCardIndex = index;
                      }
                    });
                  },
                ),
            body: LeafletMap(
              isDraggingPanel: _isDraggingPanel,
              userPosition: _userPosition,
              selectedEstate: _selectedEstate,
              selectedStop: _selectedStop,
            ),
            onPanelSlide: (position) {
              setState(() {
                _isDraggingPanel = position > 0.0 && position < 1.0;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeBar(
              estateOnTap: _showEstateFilterSheet,
              estateTitle: _selectedEstate?.estateTitleZh ?? '-',
              locationOnTap: _showStopFilterSheet,
              stopTitle: _selectedStop?.stopNameZh ?? '-',
            ),
          ),
        ],
      ),
    );
  }
}
