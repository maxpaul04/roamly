import 'dart:async';
import 'package:flutter/material.dart';
import '../services/city_api_service.dart';
import '../themes/colors.dart';

enum SearchCategory { cities, users }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final CityApiService _apiService = CityApiService();
  final TextEditingController _searchController = TextEditingController();
  
  SearchCategory _selectedCategory = SearchCategory.cities;
  List<CitySearchResult> _cityResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _cityResults = [];
        _isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (_selectedCategory == SearchCategory.users) return;

      setState(() => _isSearching = true);
      
      try {
        final results = await _apiService.searchCities(query);
        if (mounted) {
          setState(() {
            _cityResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _cityResults = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                // Toggle Switch
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<SearchCategory>(
                    segments: const [
                      ButtonSegment<SearchCategory>(
                        value: SearchCategory.cities,
                        label: Text('Cities'),
                        icon: Icon(Icons.location_city, size: 20),
                      ),
                      ButtonSegment<SearchCategory>(
                        value: SearchCategory.users,
                        label: Text('Users'),
                        icon: Icon(Icons.people, size: 20),
                      ),
                    ],
                    selected: {_selectedCategory},
                    showSelectedIcon: false,
                    onSelectionChanged: (Set<SearchCategory> newSelection) {
                      setState(() {
                        _selectedCategory = newSelection.first;
                        _cityResults = [];
                        _isSearching = false;
                        _searchController.clear();
                      });
                      FocusScope.of(context).unfocus();
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: AppColors.primaryOrange.withValues(alpha: 0.15),
                      selectedForegroundColor: AppColors.primaryOrange,
                      side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: _selectedCategory == SearchCategory.cities 
                        ? 'Search for a city...' 
                        : 'Search for travelers...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryOrange),
                    filled: true,
                    fillColor: isDark 
                        ? AppColors.surfaceCardDark 
                        : Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark 
                            ? Colors.white.withValues(alpha: 0.1) 
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ],
            ),
          ),

          // Loading Indicator
          if (_isSearching)
            const LinearProgressIndicator(minHeight: 2, backgroundColor: Colors.transparent),

          // Content Area
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    
    if (_selectedCategory == SearchCategory.users) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              'TODO: User search',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryLight
              ),
            ),
          ],
        ),
      );
    }

    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: AppColors.primaryOrange.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Search for a city to explore',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryLight
              ),
            ),
          ],
        ),
      );
    }

    if (!_isSearching && _cityResults.isEmpty && query.length >= 2) {
      return const Center(child: Text('No cities found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _cityResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final city = _cityResults[index];
        return Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light
                ? Colors.white
                : AppColors.surfaceCardDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              city.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(city.country, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              FocusScope.of(context).unfocus();
              // Placeholder for future navigation
            },
          ),
        );
      },
    );
  }
}
