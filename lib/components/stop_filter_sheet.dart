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
    return Container(
      padding: const EdgeInsets.all(16),
      // Loads stops asynchronously
      child: FutureBuilder<List<Stop>>(
        future: DatabaseHelper.instance.getStopsForEstate(estateId),
        builder: (context, snapshot) {
          // Shows loading indicator while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Handles errors or empty stop list
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('沒有可用的停靠站'));
          }

          final stops = snapshot.data!;
          // Displays scrollable list of stops
          return ListView.builder(
            shrinkWrap: true,
            itemCount: stops.length,
            itemBuilder: (context, index) {
              final stop = stops[index];
              // Each stop is a tappable tile
              return ListTile(
                title: Text(stop.stopNameZh),
                onTap: () {
                  // Triggers callback and closes sheet
                  onStopSelected(stop);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}