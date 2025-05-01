import 'package:flutter/material.dart';

// Stateful widget to display a shuttle route card with ETA information.
// Toggles expansion to show upcoming ETAs when tapped.
// Uses ValueListenableBuilder for smooth ETA updates.
class ShuttleCard extends StatefulWidget {
  final String route;
  final String info;
  final String eta;
  final List<String> upcomingEta;

  const ShuttleCard({
    super.key,
    required this.route,
    required this.info,
    required this.eta,
    required this.upcomingEta,
  });

  @override
  _ShuttleCardState createState() => _ShuttleCardState();
}

class _ShuttleCardState extends State<ShuttleCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final typescale = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        // Card Styling
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: color.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // Content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Route
                Text(
                  widget.route,
                  style: typescale.titleMedium!.copyWith(
                    color: color.onSurfaceVariant
                  ),
                ),
                // Info
                Text(
                  widget.info,
                  style: typescale.bodyMedium!.copyWith(
                    color: color.onSurfaceVariant
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // ETA
            ValueListenableBuilder<String>(
              valueListenable: ValueNotifier<String>(widget.eta),
              builder: (context, eta, child) {
                return Text(
                  eta,
                  style: typescale.titleLarge!.copyWith(
                    color: color.onSurface,
                  ),
                );
              },
            ),
            // Upcoming ETA (Expandable)
            ClipRect(
              child: AnimatedContainer(
                // Config
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _isExpanded
                    ? (widget.upcomingEta.length * 32.0 + 40.0)
                    : 0.0,
                // Content
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // Icon & Title
                      Row(
                        children: [
                          const Icon(Icons.departure_board, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '稍後班次',
                            style: typescale.labelSmall!.copyWith(
                              color: color.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Upcoming ETA
                      ValueListenableBuilder<List<String>>(
                        valueListenable: ValueNotifier<List<String>>(widget.upcomingEta),
                        builder: (context, upcomingEta, child) {
                          return Column(
                            children: upcomingEta.map((eta) => Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 34,
                                  alignment: Alignment.center,
                                  child: VerticalDivider(
                                    width: 1,
                                    color: color.outlineVariant,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    eta,
                                    style: typescale.bodyLarge!.copyWith(
                                      color: color.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            )).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}