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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onToggle,
      child: Container(

        // Card Styling
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: colorScheme.surfaceContainer,
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
                  style: textTheme.titleMedium!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                // Info
                Text(
                  info,
                  style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
                  style: textTheme.titleLarge!.copyWith(
                    color: colorScheme.onSurface,
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
                            style: textTheme.labelSmall!.copyWith(
                              color: colorScheme.onSurfaceVariant,
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
                                  spacing: 4,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 34,
                                      alignment: Alignment.center,
                                      child: VerticalDivider(
                                        width: 1,
                                        color: colorScheme.outlineVariant,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        '- 分鐘',
                                        style: textTheme.bodyLarge!.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 4,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 34,
                                      alignment: Alignment.center,
                                      child: VerticalDivider(
                                        width: 1,
                                        color: colorScheme.outlineVariant,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        '- 分鐘',
                                        style: textTheme.bodyLarge!.copyWith(
                                          color: colorScheme.onSurface,
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
                              spacing: 4,
                              children: [
                                Container(
                                  width: 16,
                                  height: 34,
                                  alignment: Alignment.center,
                                  child: VerticalDivider(
                                    width: 1,
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    eta,
                                    style: textTheme.bodyLarge!.copyWith(
                                      color: colorScheme.onSurface,
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