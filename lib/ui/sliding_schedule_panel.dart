import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/ui/shuttle_card.dart';

class SlidingSchedulePanel extends StatelessWidget {
  final ScrollController scrollController;
  final double overlapAmount;
  final List<Map<String, dynamic>> routeData;
  final ValueNotifier<List<Map<String, dynamic>>> etaNotifier;
  final int? expandedCardIndex;
  final Function(int) onToggleCard;
  final bool hasLocationPermission;
  final ValueNotifier<String> languageNotifier;

  const SlidingSchedulePanel({
    super.key,
    required this.scrollController,
    required this.overlapAmount,
    required this.routeData,
    required this.etaNotifier,
    required this.expandedCardIndex,
    required this.onToggleCard,
    required this.hasLocationPermission,
    required this.languageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Draggable handle
          Container(
            height: 4,
            width: 32,
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Content area
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: etaNotifier,
              builder: (context, routeDataValue, child) {
                if (routeDataValue.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ValueListenableBuilder<String>(
                  valueListenable: languageNotifier,
                  builder: (context, languageCode, child) {
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(top: 24),
                      itemCount: routeDataValue.length,
                      itemBuilder: (context, index) {
                        final data = routeDataValue[index];
                        final route = data['route'] as Routes?;
                        final etaNotifier = data['etaNotifier'] as ValueNotifier<String>;
                        final upcomingEtaNotifier =
                            data['upcomingEtaNotifier'] as ValueNotifier<List<String>>;

                        if (route == null) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Card(
                              child: ListTile(
                                title: Text('Error'),
                                subtitle: Text('Invalid route data'),
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                          child: ShuttleCard(
                            routeId: route.routeId,
                            route: languageCode == 'zh' ? route.routeNameZh : route.routeNameEn,
                            info: languageCode == 'zh' ? route.infoZh : route.infoEn,
                            eta: etaNotifier,
                            upcomingEta: upcomingEtaNotifier,
                            isExpanded: expandedCardIndex == index,
                            onToggle: () => onToggleCard(index),
                            languageNotifier: languageNotifier,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Location Permission Reminder
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: etaNotifier,
            builder: (context, routeDataValue, child) {
              if (!hasLocationPermission && routeDataValue.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Geolocator.openAppSettings();
                        },
                        child: Text(
                          '按此啟用定位服務',
                          style: textTheme.labelMedium!.copyWith(
                            color: colorScheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: colorScheme.primary,
                          ),
                        ),
                      ),
                      Text(
                        '以尋找最接近你的車站',
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}