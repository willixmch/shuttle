import 'package:flutter/material.dart';
import 'package:shuttle/components/shuttle_card.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/models/route.dart';
import 'package:shuttle/models/estate.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Fetches routes and their estate information from the database.
  Future<List<Map<String, dynamic>>> _fetchRoutesWithEstates() async {
    final routes = await _dbHelper.getAllRoutes();
    final List<Map<String, dynamic>> routeData = [];

    for (var route in routes) {
      final estate = await _dbHelper.getEstateById(route.estateId);
      if (estate != null) {
        routeData.add({
          'route': route,
          'estate': estate,
        });
      }
    }

    return routeData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The ReGent'),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchRoutesWithEstates(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading indicator while fetching data.
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Show error message if data fetching fails.
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Show message if no routes are found.
              return const Center(child: Text('No routes available'));
            }

            // Build list of ShuttleCard widgets from fetched data.
            final routeData = snapshot.data!;
            return ListView.builder(
              itemCount: routeData.length,
              itemBuilder: (context, index) {
                final route = routeData[index]['route'] as Routes;
                final estate = routeData[index]['estate'] as Estate;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ShuttleCard(
                    route: route.routeName,
                    info: route.info,
                    eta: 'N/A', // Placeholder until Step 4 (ETA calculation).
                    upcomingEta: [], // Placeholder until Step 4.
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}