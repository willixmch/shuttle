import 'package:flutter/material.dart';
import 'package:shuttle/components/shuttle_card.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/models/routes.dart' as model; // Alias to avoid conflicts
import 'package:shuttle/utils/eta_calculator.dart';

// Stateful widget to display the home page with a list of shuttle routes.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Fetches routes, their estate information, and calculated ETAs from the database.
  Future<List<Map<String, dynamic>>> _fetchRoutesWithEtas() async {
    final routes = await _dbHelper.getAllRoutes();
    final List<Map<String, dynamic>> routeData = [];
    final currentTime = DateTime.now();
    final dayType = EtaCalculator.getDayType(currentTime);

    for (var route in routes) {
      final estate = await _dbHelper.getEstateById(route.estateId);
      final schedules = await _dbHelper.getSchedulesForRoute(route.routeId, dayType);
      final etaData = EtaCalculator.calculateEtas(schedules, currentTime);

      if (estate != null) {
        routeData.add({
          'route': route,
          'estate': estate,
          'eta': etaData['eta'],
          'upcomingEta': etaData['upcomingEta'],
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
          future: _fetchRoutesWithEtas(),
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
                final route = routeData[index]['route'] as model.Routes;
                final eta = routeData[index]['eta'] as String;
                final upcomingEta = routeData[index]['upcomingEta'] as List<String>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ShuttleCard(
                    route: route.routeName,
                    info: route.info,
                    eta: eta,
                    upcomingEta: upcomingEta,
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