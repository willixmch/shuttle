import 'package:flutter/material.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shuttle/l10n/generated/app_localizations.dart';

class RouteDetails extends StatefulWidget {
  final String routeId;
  final String routeName;
  final int initialTab;
  final ValueNotifier<String> languageNotifier;

  const RouteDetails({
    super.key,
    required this.routeId,
    required this.routeName,
    this.initialTab = 0,
    required this.languageNotifier,
  });

  @override
  RouteDetailsState createState() => RouteDetailsState();
}

class RouteDetailsState extends State<RouteDetails> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late int _selectedSegment;
  late final PageController _pageController;
  Map<String, List<Schedule>> _schedules = {};
  List<Stop> _stopsName = [];
  Routes? _route;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedSegment = widget.initialTab;
    _pageController = PageController(initialPage: _selectedSegment);
    _loadRouteData();
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
    final localizations = AppLocalizations.of(context)!;

    return ValueListenableBuilder<String>(
      valueListenable: widget.languageNotifier,
      builder: (context, languageCode, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _route != null
                  ? (languageCode == 'zh' ? _route!.routeNameZh : _route!.routeNameEn)
                  : widget.routeName,
            ),
          ),
          body: Column(
            children: [
              // Segmented Button
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(16),
                child: SegmentedButton<int>(
                  style: ButtonStyle(
                    side: WidgetStateProperty.all(
                      BorderSide(color: colorScheme.surface),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return null;
                      }
                      return colorScheme.surfaceContainerHighest;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return null;
                      }
                      return colorScheme.onSurfaceVariant;
                    }),
                    shape: WidgetStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  segments: [
                    ButtonSegment(
                      value: 0,
                      label: Text(localizations.routeDetails),
                      icon: Icon(Icons.route),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text(localizations.schedule),
                      icon: Icon(Icons.table_view),
                    ),
                  ],
                  selected: {_selectedSegment},
                  onSelectionChanged: _onSegmentChanged,
                ),
              ),
              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const CustomPageViewScrollPhysics(),
                  children: [
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              spacing: 24,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Fare Info
                                Row(
                                  spacing: 24,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      spacing: 8,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localizations.residentFare,
                                          style: textTheme.bodyMedium!.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          _route?.residentFare ?? 'N/A',
                                          style: textTheme.displaySmall!.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      spacing: 8,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localizations.visitorFare,
                                          style: textTheme.bodyMedium!.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          _route?.visitorFare ?? 'N/A',
                                          style: textTheme.displaySmall!.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Divider
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                      color: colorScheme.outlineVariant,
                                    ),
                                    Text(
                                      localizations.stops,
                                      style: textTheme.labelMedium!.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // Stop Diagram
                                _stopsName.isNotEmpty
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: _stopsName.asMap().entries.expand((entry) {
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
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        languageCode == 'zh'
                                                            ? stop.stopNameZh
                                                            : stop.stopNameEn,
                                                        style: textTheme.titleMedium!.copyWith(
                                                          color: colorScheme.onSurface,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      Text(
                                                        stop.etaOffset == 0
                                                            ? localizations.origin
                                                            : stop.etaOffset == -1
                                                                ? localizations.circular
                                                                : '${stop.etaOffset} ${localizations.minutes}',
                                                        style: textTheme.bodyMedium!.copyWith(
                                                          color: colorScheme.onSurfaceVariant,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ];
                                          if (index < _stopsName.length - 1) {
                                            widgets.add(
                                              Container(
                                                height: 28,
                                                alignment: Alignment.bottomLeft,
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Stack(
                                                  clipBehavior: Clip.none, // Ensure Stack doesn't clip either
                                                  children: [
                                                    Positioned(
                                                      bottom: -10, // Anchor SVG to the bottom
                                                      child: SvgPicture.asset(
                                                        'lib/assets/stop_connector.svg',
                                                        width: 4,
                                                        height: 48,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                          return widgets;
                                        }).toList(),
                                      )
                                    : Text(
                                        'No Stop Data',
                                        style: textTheme.bodyLarge!.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final dayTypes = [
                                  {'key': 'workday', 'label': localizations.workday},
                                  {'key': 'saturday', 'label': localizations.saturday},
                                  {'key': 'sunday', 'label': localizations.sunday},
                                  {'key': 'public_holiday', 'label': localizations.publicHoliday},
                                ];

                                return Column(
                                  children: dayTypes.map((dayType) {
                                    return Padding(
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
                                                      : localizations.noService,
                                                  style: textTheme.bodyMedium!.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
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
      },
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