import 'package:flutter/material.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';

class StopFilterSheet extends StatelessWidget {
  final String estateId;
  final ValueChanged<Stop> onStopSelected;

  const StopFilterSheet({
    super.key,
    required this.estateId,
    required this.onStopSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Text('上客點', style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: FutureBuilder<List<Stop>>(
              future: DatabaseHelper.instance.getBordingStopsForEstate(estateId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('沒有可用的停靠站'));
                }

                final stops = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: stops.length,
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    // Each stop is a tappable tile
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                      title: Text(stop.stopNameZh, style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
                      onTap: () {
                        onStopSelected(stop);
                        Navigator.pop(context);
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