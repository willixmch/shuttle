import 'package:flutter/material.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/services/database_helper.dart';

// Page to display route details and schedule for a selected shuttle route
class ShuttleRoutePage extends StatefulWidget {
  final String routeId; // ID of the selected route
  final String routeName; // Name of the selected route for app bar
  final int initialTab; // 0 for Route Details, 1 for Schedule

  const ShuttleRoutePage({
    super.key,
    required this.routeId,
    required this.routeName,
    this.initialTab = 0,
  });

  @override
  ShuttleRoutePageState createState() => ShuttleRoutePageState();
}

class ShuttleRoutePageState extends State<ShuttleRoutePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late int _selectedSegment;
  final PageController _pageController = PageController();
  Routes? _route; // Store route details
  Map<String, List<Schedule>> _schedules = {}; // Store schedules by day type
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _selectedSegment = widget.initialTab; // Set initial tab from navigation
    _loadRouteData(); // Fetch route data
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadRouteData() async {
    try {
      // Fetch route details
      final routes = await _dbHelper.getAllRoutes();
      final route = routes.firstWhere((r) => r.routeId == widget.routeId);

      // Fetch schedules for all day types
      final schedules = <String, List<Schedule>>{};
      for (var dayType in ['workday', 'saturday', 'sunday', 'public_holiday']) {
        final scheduleList = await _dbHelper.getSchedulesForRoute(widget.routeId, dayType);
        schedules[dayType] = scheduleList;
      }

      if (mounted) {
        setState(() {
          _route = route;
          _schedules = schedules;
          _isLoading = false;
        });
        // Set initial page after loading and PageView is built
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_selectedSegment);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading route data: $e')),
        );
      }
    }
  }

  void _onSegmentChanged(Set<int> newSelection) {
    setState(() {
      _selectedSegment = newSelection.first;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _selectedSegment,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedSegment = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routeName),
        backgroundColor: colorScheme.surfaceContainer,
      ),
      body: Column(
        children: [
          // Segmented Button for tab switching
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('路線詳情'),
                  icon: Icon(Icons.route),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('時間表'),
                  icon: Icon(Icons.table_view),
                ),
              ],
              selected: {_selectedSegment},
              onSelectionChanged: _onSegmentChanged,
            ),
          ),
          // Content area with swipeable PageView
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const CustomPageViewScrollPhysics(),
                    children: [
                      // Placeholder for Route Details
                      Container(
                        color: colorScheme.surfaceContainerLowest,
                        child: Center(
                          child: Text(
                            _route != null
                                ? 'Route Details: ${_route!.routeName}\nInfo: ${_route!.info}'
                                : 'No Route Data',
                          ),
                        ),
                      ),
                      // Placeholder for Schedule
                      Container(
                        color: colorScheme.surfaceContainerLowest,
                        child: Center(
                          child: Text(
                            _schedules.isNotEmpty
                                ? 'Schedules Loaded: ${_schedules.keys.join(", ")}'
                                : 'No Schedules Available',
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// Custom scroll physics for PageView to enhance fling behavior
class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 600.0; // Require slightly faster swipe for fling

  @override
  double get dragStartDistanceMotionThreshold => 5.0; // Start drag earlier

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);
    if (velocity.abs() >= minFlingVelocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return super.createBallisticSimulation(position, velocity);
  }
}