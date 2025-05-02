import 'package:flutter/material.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/services/database_helper.dart';

// A bottom sheet widget for filtering estates with a search bar and estate list.
class EstateFilterSheet extends StatefulWidget {
  final ValueChanged<Estate> onEstateSelected;

  const EstateFilterSheet({
    super.key,
    required this.onEstateSelected,
  });

  @override
  _EstateFilterSheetState createState() => _EstateFilterSheetState();
}

class _EstateFilterSheetState extends State<EstateFilterSheet> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Estate> _estates = [];
  List<Estate> _filteredEstates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEstates();
    _searchController.addListener(_filterEstates);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Loads all estates from the database.
  Future<void> _loadEstates() async {
    final estates = await _dbHelper.getAllEstates();
    if (mounted) {
      setState(() {
        _estates = estates;
        _filteredEstates = estates;
        _isLoading = false;
      });
    }
  }

  // Filters estates based on the search query (searches both English and Chinese titles).
  void _filterEstates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEstates = _estates.where((estate) {
        return estate.estateTitleEn.toLowerCase().contains(query) ||
            estate.estateTitleZh.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    final color = Theme.of(context).colorScheme;
    final typescale = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
      child: Column(
        children: [
          // Material 3 SearchBar without shadow
          SearchBar(
            controller: _searchController,
            hintText: '搜尋屋苑...',
            leading: const Icon(Icons.search),
            textStyle: WidgetStatePropertyAll(typescale.bodyLarge),
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0)),
            elevation: const WidgetStatePropertyAll(0.0), // No shadow
          ),
          const SizedBox(height: 16.0),
          // Estate list or loading indicator
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEstates.isEmpty
                    ? const Center(child: Text('沒有結果'))
                    : ListView.separated(
                        itemCount: _filteredEstates.length,
                        itemBuilder: (context, index) {
                          final estate = _filteredEstates[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0), 
                            title: Text(
                              estate.estateTitleEn,
                              style: typescale.bodyLarge?.copyWith(
                                color: color.onSurfaceVariant,
                              ),
                            ),
                            subtitle: Text(
                              estate.estateTitleZh,
                              style: typescale.titleMedium?.copyWith(
                                color: color.onSurface,
                              ),
                            ),
                            onTap: () {
                              widget.onEstateSelected(estate);
                              Navigator.pop(context); // Close bottom sheet
                            },
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(height: 1,), // Add divider between items
                      ),
          ),
        ],
      ),
    );
  }
}