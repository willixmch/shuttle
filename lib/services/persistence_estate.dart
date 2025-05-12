import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/services/database_helper.dart';

// Service to handle selected estate using SharedPreferences.
class PersistenceEstate {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Loads persisted estate, defaulting to first available if none or invalid.
  Future<Map<String, dynamic>> estateQuery() async {
    final prefs = await SharedPreferences.getInstance();
    Estate? selectedEstate;

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

    return {
      'estate': selectedEstate,
    };
  }

  // Saves the selected estate to SharedPreferences.
  Future<void> saveEstate(Estate estate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedEstateId', estate.estateId);
  }
}