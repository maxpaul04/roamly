import 'dart:async';
import 'package:flutter/material.dart';
import '../services/city_api_service.dart';
import '../services/mock_city_rating_service.dart';
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

  void _showCityDetails(CitySearchResult city) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CityDetailsSheet(city: city),
    );
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
        return Material(
          color: theme.brightness == Brightness.light
              ? Colors.white
              : AppColors.surfaceCardDark,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
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
              _showCityDetails(city);
            },
          ),
        );
      },
    );
  }
}

class _CityDetailsSheet extends StatefulWidget {
  final CitySearchResult city;

  const _CityDetailsSheet({required this.city});

  @override
  State<_CityDetailsSheet> createState() => _CityDetailsSheetState();
}

class _CityDetailsSheetState extends State<_CityDetailsSheet> {
  //deliberate trade-off: global ratings for each city do not get persisted but get generated again each time it is searched
  //in a real App this would be saved somewhere globally for each user to be identical, here it is only a mocked function
  late final Map<double, int> _ratingDistribution;
  late final double _averageRating;
  final _ratingService = MockCityRatingService();

  @override
  void initState() {
    super.initState();
    // Requirements: generate exactly once and store in local state for the sheet's lifetime
    _ratingDistribution = _ratingService.generateRatingDistribution();
    _averageRating = _ratingService.averageRating(_ratingDistribution);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceCardDark : AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Visual handle for dragging
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              Text(
                widget.city.name,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                widget.city.country,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Average Rating Number
              Row(
                children: [
                  Text(
                    '${_averageRating.toStringAsFixed(1)} ★',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Rating Chart Placeholder
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text('Rating chart placeholder'),
              ),
              
              const SizedBox(height: 32),
              
              // TODO: Add wishlist toggle button
              // TODO: Add "Log this city" button
              
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
