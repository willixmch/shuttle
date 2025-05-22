import 'package:flutter/material.dart';
import 'package:shuttle/l10n/generated/app_localizations.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';

class StopFilterSheet extends StatelessWidget {
  final String estateId;
  final ValueChanged<Stop> onStopSelected;
  final ValueNotifier<String> languageNotifier; // Added

  const StopFilterSheet({
    super.key,
    required this.estateId,
    required this.onStopSelected,
    required this.languageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Text(localizations.pickUpStop, style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: FutureBuilder<List<Stop>>(
              future: DatabaseHelper.instance.getBoardingStopsForEstate(estateId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No Stop'));
                }

                final stops = snapshot.data!;
                return ValueListenableBuilder<String>(
                  valueListenable: languageNotifier,
                  builder: (context, languageCode, child) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: stops.length,
                      itemBuilder: (context, index) {
                        final stop = stops[index];
                        // Each stop is a tappable tile
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                          title: Text(
                            languageCode == 'zh' ? stop.stopNameZh : stop.stopNameEn,
                            style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                          ),
                          onTap: () {
                            onStopSelected(stop);
                            Navigator.pop(context);
                          },
                        );
                      },
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