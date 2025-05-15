import 'package:flutter/material.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';

// Page to display route details and schedule for a selected shuttle route
class RouteDetails extends StatefulWidget {
  final String routeId; // ID of the selected route
  final String routeName; // Name of the selected route for app bar
  final int initialTab; // 0 for Route Details, 1 for Schedule

  const RouteDetails({
    super.key,
    required this.routeId,
    required this.routeName,
    this.initialTab = 0,
  });

  @override
  RouteDetailsState createState() => RouteDetailsState();
}

class RouteDetailsState extends State<RouteDetails> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late int _selectedSegment;
  late final PageController _pageController;
  Routes? _route; // Store route details
  Map<String, List<Schedule>> _schedules = {}; // Store schedules by day type
  List<Stop> _stopsName = []; // Store stops for the route
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _selectedSegment = widget.initialTab; // Set initial tab from navigation
    _pageController = PageController(initialPage: _selectedSegment); // Set initial page
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

      // Fetch stops for the route
      final stopsName = await _dbHelper.getStopsForRoute(widget.routeId);

      if (mounted) {
        setState(() {
          _route = route;
          _schedules = schedules;
          _stopsName = stopsName;
          _isLoading = false;
        });
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
      _pageController.animateToPage(
        _selectedSegment,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
      );
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routeName),
      ),
      body: Column(
        children: [

          // Segmented Button for tab switching
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
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
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const CustomPageViewScrollPhysics(),
              children: [
                // Route Details UI
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          spacing: 24,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Route ID
                            Text(
                              widget.routeId,
                              style: textTheme.headlineLarge!.copyWith(
                              color: colorScheme.onSurface
                              )
                            ),

                            Divider(
                              color: colorScheme.outlineVariant,
                            ),

                            // List of Stops
                            _stopsName.isNotEmpty
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _stopsName
                                        .map((stop) => Padding(
                                              padding: const EdgeInsets.only(bottom: 4.0),
                                              child: Text(
                                                stop.stopNameZh,
                                                style: textTheme.bodyLarge!.copyWith(
                                                color: colorScheme.onSurface
                                                )
                                              ),
                                            ))
                                        .toList(),
                                  )
                                : Text(
                                    '無巴士站資料',
                                    style: textTheme.bodyLarge!.copyWith(
                                    color: colorScheme.onSurface
                                    )
                                  ),
                          ],
                        ),
                      ),
                // Schedule UI
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          spacing: 24,
                          children: [
                            // Workday Schedule
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    spacing: 8,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '星期一至五（公眾假期除外）',
                                        style: textTheme.titleMedium!.copyWith(
                                        color: colorScheme.onSurface
                                        )
                                      ),
                                      Text(
                                        _schedules['workday']!.isNotEmpty
                                            ? _schedules['workday']!
                                                .map((s) => s.departureTime)
                                                .join(', ')
                                            : '沒有班次',
                                        style: textTheme.bodyMedium!.copyWith(
                                        color: colorScheme.onSurfaceVariant
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Saturday Schedule
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    spacing: 8,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '星期六',
                                        style: textTheme.titleMedium!.copyWith(
                                        color: colorScheme.onSurface
                                        )
                                      ),
                                      Text(
                                        _schedules['saturday']!.isNotEmpty
                                            ? _schedules['saturday']!
                                                .map((s) => s.departureTime)
                                                .join(', ')
                                            : '沒有班次',
                                        style: textTheme.bodyMedium!.copyWith(
                                        color: colorScheme.onSurfaceVariant
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Sunday and Public Holiday Schedule
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    spacing: 8,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '星期日及公眾假期',
                                        style: textTheme.titleMedium!.copyWith(
                                        color: colorScheme.onSurface
                                        )
                                      ),

                                      Text(
                                        _schedules['public_holiday']!.isNotEmpty
                                            ? _schedules['public_holiday']!
                                                .map((s) => s.departureTime)
                                                .join(', ')
                                            : '沒有班次',
                                        style: textTheme.bodyMedium!.copyWith(
                                        color: colorScheme.onSurfaceVariant
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
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
  const CustomPageViewScrollPhysics({super.parent});

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