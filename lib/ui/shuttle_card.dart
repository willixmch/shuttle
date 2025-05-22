import 'package:flutter/material.dart';
import 'package:shuttle/l10n/generated/app_localizations.dart';
import 'package:shuttle/pages/route_details.dart';

class ShuttleCard extends StatelessWidget {
  final String routeId;
  final String route;
  final String info;
  final ValueNotifier<String> eta;
  final ValueNotifier<List<String>> upcomingEta;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueNotifier<String> languageNotifier;

  const ShuttleCard({
    super.key,
    required this.routeId,
    required this.route,
    required this.info,
    required this.eta,
    required this.upcomingEta,
    required this.isExpanded,
    required this.onToggle,
    required this.languageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        // Card Styling
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: isExpanded
                    ? (upcomingEta.value.isEmpty
                        ? 2 * 32.0 + 100.0
                        : upcomingEta.value.length * 32.0 + 100.0)
                    : 0.0,
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
                            localizations.upcomingEta,
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
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        '- ${localizations.minutes}',
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
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        '- ${localizations.minutes}',
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
                            children: upcomingEtaValue
                                .map(
                                  (eta) => Row(
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Text(
                                          eta,
                                          style: textTheme.bodyLarge!.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      // Buttons
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          spacing: 12,
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      colorScheme.surfaceContainerHighest,
                                  foregroundColor: colorScheme.onSurfaceVariant,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RouteDetails(
                                        routeId: routeId,
                                        routeName: route,
                                        initialTab: 0,
                                        languageNotifier: languageNotifier,
                                      ),
                                    ),
                                  );
                                },
                                label: Text(localizations.routeDetails),
                                icon: const Icon(Icons.route),
                              ),
                            ),
                            Expanded(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.primaryContainer,
                                  foregroundColor:
                                      colorScheme.onPrimaryContainer,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RouteDetails(
                                        routeId: routeId,
                                        routeName: route,
                                        initialTab: 1,
                                        languageNotifier: languageNotifier,
                                      ),
                                    ),
                                  );
                                },
                                label: Text(localizations.schedule),
                                icon: const Icon(Icons.table_view),
                              ),
                            ),
                          ],
                        ),
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