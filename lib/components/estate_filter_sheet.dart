import 'package:flutter/material.dart'; 
import 'package:shuttle/models/estate.dart'; 
import 'package:shuttle/services/database_helper.dart'; 

// Bottom sheet for filtering estates with search and list
class EstateFilterSheet extends StatefulWidget {
  final ValueChanged<Estate> onEstateSelected; // Callback for selected estate

  const EstateFilterSheet({
    super.key,
    required this.onEstateSelected,
  });

  @override
  _EstateFilterSheetState createState() => _EstateFilterSheetState();
}

class _EstateFilterSheetState extends State<EstateFilterSheet> {
  final TextEditingController _searchController = TextEditingController(); // Search bar input controller
  final FocusNode _searchFocusNode = FocusNode(); // Auto search bar focus
  List<Estate> _estates = []; // Full estate list
  List<Estate> _filteredEstates = []; // Filtered estate list
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _loadEstates(); // Fetch estates
    _searchController.addListener(_filterEstates); // Listen for search input
    // Auto-focus search bar after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean up search controller
    _searchFocusNode.dispose(); // Clean up focus node
    super.dispose();
  }

  // Fetch all estates from database
  Future<void> _loadEstates() async {
    final estates = await DatabaseHelper.instance.getAllEstates();
    if (mounted) {
      setState(() {
        _estates = estates;
        _filteredEstates = estates;
        _isLoading = false;
      });
    }
  }

  // Filter estates by search query (English/Chinese titles)
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
      padding: const EdgeInsets.symmetric(horizontal: 16), // Padding for content
      height: MediaQuery.of(context).size.height * 0.8, // 80% screen height
      child: Column(
        children: [
          // Search bar for filtering estates
          SearchBar(
            controller: _searchController, // Connects to input
            focusNode: _searchFocusNode, // Manages focus
            hintText: '搜尋屋苑...', // Placeholder text
            leading: const Icon(Icons.search), // Search icon
            textStyle: WidgetStatePropertyAll(typescale.bodyLarge), // Text style
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0)), // Inner padding
            elevation: const WidgetStatePropertyAll(0.0), // No shadow
          ),
          const SizedBox(height: 16.0), // Space below search bar
          // List of estates or loading/no results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator()) // Show loading
                : _filteredEstates.isEmpty
                    ? const Center(child: Text('沒有結果')) // Show no results
                    : ListView.separated(
                        itemCount: _filteredEstates.length, // Number of estates
                        itemBuilder: (context, index) {
                          final estate = _filteredEstates[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0), // Item padding
                            title: Text(
                              estate.estateTitleEn, // English title
                              style: typescale.bodyLarge?.copyWith(color: color.onSurfaceVariant),
                            ),
                            subtitle: Text(
                              estate.estateTitleZh, // Chinese title
                              style: typescale.titleMedium?.copyWith(color: color.onSurface),
                            ),
                            onTap: () {
                              widget.onEstateSelected(estate); // Call callback
                              Navigator.pop(context); // Close sheet
                            },
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(height: 1), // Divider between items
                      ),
          ),
        ],
      ),
    );
  }
}