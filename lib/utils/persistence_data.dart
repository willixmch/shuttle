import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';

// Service to handle persistence of selected estate and stop using SharedPreferences.
class PersistenceData {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Loads persisted estate and stop, defaulting to first available if none or invalid.
  Future<Map<String, dynamic>> loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    Estate? selectedEstate;
    Stop? selectedStop;

    // Try to load persisted estate
    final estateId = prefs.getString('selectedEstateId');
    if (estateId != null) {
      selectedEstate = await _dbHelper.getEstateById(estateId);
    }

    // Default to first estate if none persisted or invalid
    if (selectedEstate == null) {
      final estates = await _dbHelper.getAllEstates();
      if (estates.isNotEmpty) {
        selectedEstate = estates.first;
        await prefs.setString('selectedEstateId', selectedEstate.estateId);
      }
    }

    // Try to load persisted stop if estate is valid
    if (selectedEstate != null) {
      final stopId = prefs.getString('selectedStopId');
      final stops = await _dbHelper.getStopsForEstate(selectedEstate.estateId);
      if (stopId != null && stops.isNotEmpty) {
        selectedStop = stops.firstWhere(
          (stop) => stop.stopId == stopId,
          orElse: () => stops.first,
        );
      } else if (stops.isNotEmpty) {
        selectedStop = stops.first;
      }

      if (selectedStop != null) {
        await prefs.setString('selectedStopId', selectedStop.stopId);
      } else {
        await prefs.remove('selectedStopId');
      }
    }

    return {
      'estate': selectedEstate,
      'stop': selectedStop,
    };
  }

  // Saves the selected estate to SharedPreferences.
  Future<void> saveEstate(Estate estate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedEstateId', estate.estateId);
  }

  // Saves the selected stop to SharedPreferences.
  Future<void> saveStop(Stop stop) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedStopId', stop.stopId);
  }

  // Clears the persisted stop from SharedPreferences.
  Future<void> clearStop() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedStopId');
  }
}