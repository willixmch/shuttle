import 'package:flutter/material.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/services/persistence_estate.dart';
import 'package:shuttle/pages/onboarding_location_permission.dart';

class OnboardingEstateSelection extends StatefulWidget {
  final void Function(VoidCallback) toggleLanguage;
  final ValueNotifier<String> languageNotifier;

  const OnboardingEstateSelection({
    super.key,
    required this.toggleLanguage,
    required this.languageNotifier,
  });

  @override
  OnboardingEstateSelectionState createState() => OnboardingEstateSelectionState();
}

class OnboardingEstateSelectionState extends State<OnboardingEstateSelection> {
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Text('Select your estate', style: textTheme.headlineLarge),
              ),
            ),
            SearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: 'Search estates',
              leading: const Icon(Icons.search),
              textStyle: WidgetStatePropertyAll(textTheme.bodyLarge),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0)),
              elevation: const WidgetStatePropertyAll(0.0),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredEstates.isEmpty
                      ? const Center(child: Text('No results found'))
                      : ListView.separated(
                          padding: EdgeInsets.only(bottom: 20),
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
                                  MaterialPageRoute(
                                    builder: (context) => OnboardingLocationPermission(
                                      toggleLanguage: widget.toggleLanguage,
                                      languageNotifier: widget.languageNotifier,
                                    ),
                                  ),
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