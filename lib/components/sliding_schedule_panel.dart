import 'package:flutter/material.dart';
import 'package:shuttle/components/shuttle_card.dart';
import 'package:shuttle/models/routes.dart';

class SlidingSchedulePanel extends StatelessWidget {
  final ScrollController scrollController;
  final double overlapAmount;
  final List<Map<String, dynamic>> routeData;
  final ValueNotifier<List<Map<String, dynamic>>> etaNotifier;
  final int? expandedCardIndex;
  final Function(int) onToggleCard;

  const SlidingSchedulePanel({
    super.key,
    required this.scrollController,
    required this.overlapAmount,
    required this.routeData,
    required this.etaNotifier,
    required this.expandedCardIndex,
    required this.onToggleCard,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
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
              color: color.outline,
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
            
                return ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.only(top: 24), 
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
                      padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
                      child: ShuttleCard(
                        route: route.routeName,
                        info: route.info,
                        eta: etaNotifier,
                        upcomingEta: upcomingEtaNotifier,
                        isExpanded: expandedCardIndex == index,
                        onToggle: () => onToggleCard(index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}