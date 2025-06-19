import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shuttle/ui/estate_filter_sheet.dart';
import 'package:shuttle/ui/home_bar.dart';
import 'package:shuttle/ui/sliding_schedule_panel.dart';
import 'package:shuttle/ui/stop_filter_sheet.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/ui/leaflet_map.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/utils/day_type_checker.dart';
import 'package:shuttle/services/route_query.dart';
import 'package:shuttle/services/persistence_estate.dart';
import 'package:shuttle/utils/eta_calculator.dart';
import 'package:shuttle/utils/eta_refresh_timer.dart';
import 'package:shuttle/services/stop_query.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Home extends StatefulWidget {
  final void Function(VoidCallback) toggleLanguage;
  final ValueNotifier<String> languageNotifier;

  const Home({
    super.key,
    required this.toggleLanguage,
    required this.languageNotifier,
  });

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final PersistenceEstate _persistenceEstate = PersistenceEstate();
  final StopQuery _stopQuery;
  final RouteQuery _routeQuery;
  late final EtaRefreshTimer _etaRefreshTimer;
  List<Map<String, dynamic>> _cachedRouteData = [];
  late ValueNotifier<List<Map<String, dynamic>>> _etaNotifier;
  Estate? _selectedEstate;
  Stop? _selectedStop;
  int? _expandedCardIndex;
  bool _hasLocationPermission = false;

  final PanelController _panelController = PanelController();
  final double _minHeightFraction = 0.45;
  final double _maxHeightFraction = 1.0;
  final double _overlapAmount = 20.0;
  bool _isDraggingPanel = false;

  HomeState()
      : _routeQuery = RouteQuery(DatabaseHelper.instance),
        _stopQuery = StopQuery(DatabaseHelper.instance);

  @override
  void initState() {
    super.initState();
    _loadSchedule();
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
    widget.languageNotifier.addListener(_refreshEtaStrings);
  }

  @override
  void dispose() {
    _etaRefreshTimer.dispose();
    _etaNotifier.dispose();
    widget.languageNotifier.removeListener(_refreshEtaStrings);
    super.dispose();
  }

  void _refreshEtaStrings() {
    final updatedRouteData = _cachedRouteData.map((entry) {
      final eta = entry['eta'] as int?;
      final upcomingEta = (entry['upcomingEta'] as List<dynamic>?)?.cast<int>() ?? [];
      return {
        ...entry,
        'etaNotifier': ValueNotifier<String>(EtaCalculator.formatEta(eta)),
        'upcomingEtaNotifier': ValueNotifier<List<String>>(
          upcomingEta.map((e) => EtaCalculator.formatEta(e)).toList(),
        ),
      };
    }).toList();
    setState(() {
      _cachedRouteData = updatedRouteData;
      _etaNotifier.value = updatedRouteData;
    });
  }

  Future<void> _loadSchedule() async {
    // Check location permission
    final permission = await Geolocator.checkPermission();
    _hasLocationPermission = permission == LocationPermission.always || permission == LocationPermission.whileInUse;

    final persistenceEstate = await _persistenceEstate.estateQuery();
    if (mounted && persistenceEstate['estate'] != null) {
      setState(() {
        _selectedEstate = persistenceEstate['estate'];
      });
    }

    if (_selectedStop == null && _selectedEstate != null) {
      _selectedStop = await _stopQuery.getInitialStop(
        _selectedEstate!.estateId,
        _hasLocationPermission,
      );
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
      _refreshEtaStrings();
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
            await _persistenceEstate.saveEstate(estate);
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
          languageNotifier: widget.languageNotifier,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top;
    final double minHeight = screenHeight * _minHeightFraction;
    final double maxHeight = screenHeight * _maxHeightFraction + _overlapAmount;

    return ValueListenableBuilder<String>(
      valueListenable: widget.languageNotifier,
      builder: (context, languageCode, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              SlidingUpPanel(
                controller: _panelController,
                minHeight: minHeight,
                maxHeight: maxHeight,
                snapPoint: null,
                panelBuilder: (scrollController) => SlidingSchedulePanel(
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
                  hasLocationPermission: _hasLocationPermission,
                  languageNotifier: widget.languageNotifier,
                ),
                body: LeafletMap(
                  isDraggingPanel: _isDraggingPanel,
                  selectedEstate: _selectedEstate,
                  selectedStop: _selectedStop,
                  hasLocationPermission: _hasLocationPermission,
                  onStopSelected: (Stop stop) {
                    setState(() {
                      _selectedStop = stop;
                      _expandedCardIndex = null;
                    });
                    _loadSchedule();
                  },
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
                  estateTitle: languageCode == 'zh'
                      ? _selectedEstate?.estateTitleZh ?? '-'
                      : _selectedEstate?.estateTitleEn ?? '-',
                  locationOnTap: _showStopFilterSheet,
                  stopTitle: languageCode == 'zh'
                      ? _selectedStop?.stopNameZh ?? '-'
                      : _selectedStop?.stopNameEn ?? '-',
                  toggleLanguage: () => widget.toggleLanguage(_refreshEtaStrings),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}