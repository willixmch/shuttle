import 'package:flutter/material.dart';

// Widget to display a shuttle route card with ETA information.
// Expands to show upcoming ETAs based on isExpanded, controlled by parent.
class ShuttleCard extends StatelessWidget {
  final String route;
  final String info;
  final ValueNotifier<String> eta;
  final ValueNotifier<List<String>> upcomingEta;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ShuttleCard({
    super.key,
    required this.route,
    required this.info,
    required this.eta,
    required this.upcomingEta,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final typescale = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onToggle,
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
                  route,
                  style: typescale.titleMedium!.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
                // Info
                Text(
                  info,
                  style: typescale.bodyMedium!.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // ETA
            ValueListenableBuilder<String>(
              valueListenable: eta,
              builder: (context, etaValue, child) {
                return Text(
                  etaValue,
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
                height: isExpanded
                    ? (upcomingEta.value.isEmpty ? 2 * 32.0 + 40.0 : upcomingEta.value.length * 32.0 + 40.0)
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
                        valueListenable: upcomingEta,
                        builder: (context, upcomingEtaValue, child) {
                          if (upcomingEtaValue.isEmpty) {
                            return Column(
                              children: [
                                Row(
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
                                        '- 分鐘',
                                        style: typescale.bodyLarge!.copyWith(
                                          color: color.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
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
                                        '- 分鐘',
                                        style: typescale.bodyLarge!.copyWith(
                                          color: color.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: upcomingEtaValue.map((eta) => Row(
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