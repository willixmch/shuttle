import 'package:flutter/material.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                            Row(
                              spacing: 24,
                              children: [
                                Column(
                                  spacing: 4,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '住戶收費',
                                      style: textTheme.bodySmall!.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      '\$5',
                                      style: textTheme.headlineMedium!.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  spacing: 4,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '訪客收費',
                                      style: textTheme.bodySmall!.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      '\$6',
                                      style: textTheme.headlineMedium!.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(
                              color: colorScheme.outlineVariant,
                            ),
                            // List of Stops
                            _stopsName.isNotEmpty
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _stopsName
                                        .asMap()
                                        .entries
                                        .expand((entry) {
                                      final index = entry.key;
                                      final stop = entry.value;
                                      final List<Widget> widgets = [
                                        Row(
                                          spacing: 16,
                                          children: [
                                            SvgPicture.asset(
                                              'lib/assets/stop_dot.svg',
                                              height: 24,
                                              width: 24,
                                            ),
                                            Row(
                                              spacing: 8,
                                              children: [
                                                Text(
                                                  stop.stopNameZh,
                                                  style: textTheme.bodyLarge!.copyWith(
                                                    color: colorScheme.onSurface,
                                                  ),
                                                ),
                                                Text(
                                                  stop.etaOffset == 0 ? '(總站)' : '(${stop.etaOffset} 分鐘)',
                                                  style: textTheme.bodyLarge!.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            
                                          ],
                                        ),
                                      ];
                                      // Add Container between Rows, except after the last stop
                                      if (index < _stopsName.length - 1) {
                                        widgets.add(
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: SvgPicture.asset(
                                              'lib/assets/stop_connector.svg',
                                              width: 4,
                                              height: 36,
                                              ),
                                          ),
                                        );
                                      }
                                      return widgets;
                                    }).toList(),
                                  )
                                : Text(
                                    '無巴士站資料',
                                    style: textTheme.bodyLarge!.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                // Schedule UI
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final dayTypes = [
                              {
                                'key': 'workday',
                                'label': '星期一至五（公眾假期除外）',
                              },
                              {
                                'key': 'saturday',
                                'label': '星期六',
                              },
                              {
                                'key': 'public_holiday',
                                'label': '星期日及公眾假期',
                              },
                            ];

                            return Column(
                              children: dayTypes
                                  .map((dayType) => Padding(
                                        padding: const EdgeInsets.only(bottom: 24.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                spacing: 8,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    dayType['label']!,
                                                    style: textTheme.titleMedium!.copyWith(
                                                      color: colorScheme.onSurface,
                                                    ),
                                                  ),
                                                  Text(
                                                    _schedules[dayType['key']]!.isNotEmpty
                                                        ? _schedules[dayType['key']]!
                                                            .map((s) => s.departureTime)
                                                            .join(', ')
                                                        : '沒有班次',
                                                    style: textTheme.bodyMedium!.copyWith(
                                                      color: colorScheme.onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            );
                          },
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