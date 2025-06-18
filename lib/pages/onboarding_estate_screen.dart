import 'package:flutter/material.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/services/persistence_estate.dart';

class OnboardingEstateScreen extends StatefulWidget {
  const OnboardingEstateScreen({super.key});

  @override
  OnboardingEstateScreenState createState() => OnboardingEstateScreenState();
}

class OnboardingEstateScreenState extends State<OnboardingEstateScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Estate> _estates = [];
  List<Estate> _filteredEstates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEstates();
    _searchController.addListener(_filterEstates);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Estate'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: 'Search estates',
              leading: const Icon(Icons.search),
              textStyle: WidgetStatePropertyAll(textTheme.bodyLarge),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0)),
              elevation: const WidgetStatePropertyAll(0.0),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredEstates.isEmpty
                      ? const Center(child: Text('No results found'))
                      : ListView.separated(
                          itemCount: _filteredEstates.length,
                          itemBuilder: (context, index) {
                            final estate = _filteredEstates[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                              title: Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                estate.estateTitleEn,
                                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                              subtitle: Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                estate.estateTitleZh,
                                style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                              ),
                              onTap: () async {
                                await PersistenceEstate().saveEstate(estate);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Placeholder()), // Placeholder for location screen
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(height: 1),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}