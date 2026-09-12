import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roamly/models/wishlist_entry_model.dart';
import 'package:roamly/screens/profile_page.dart';
import 'package:roamly/services/user_repository.dart';
import '../models/friendship_model.dart';
import '../models/user_model.dart';
import '../services/city_repository.dart';
import '../services/comment_repository.dart';
import '../services/friendship_repository.dart';
import '../services/wishlist_repository.dart';
import '../services/city_api_service.dart';
import '../services/mock_city_rating_service.dart';
import '../themes/colors.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/friendship_action_button.dart';
import 'add_city_page.dart';

enum SearchCategory { cities, users }

class SearchPage extends StatefulWidget {
  final CityRepository repository;
  final VoidCallback onCityAdded;
  final UserRepository userRepository;
  final FriendshipRepository friendshipRepository;
  final WishlistRepository wishlistRepository;
  final CommentRepository commentRepository;

  const SearchPage({
    super.key,
    required this.repository,
    required this.onCityAdded,
    required this.userRepository,
    required this.friendshipRepository,
    required this.wishlistRepository,
    required this.commentRepository,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final CityApiService _apiService = CityApiService();
  final TextEditingController _searchController = TextEditingController();

  SearchCategory _selectedCategory = SearchCategory.cities;
  List<CitySearchResult> _cityResults = [];
  List<_UserSearchResult> _userResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Slows down search inputs to prevent redundant API and database queries.
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _cityResults = [];
        _userResults = [];
        _isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (_selectedCategory == SearchCategory.users) {
        await _searchUsers(query);
      } else {
        await _searchCities(query);
      }
    });
  }

  // Queries the external city API for matching locations.
  Future<void> _searchCities(String query) async {
    setState(() => _isSearching = true);
    try {
      final results = await _apiService.searchCities(query);
      if (mounted) setState(() { _cityResults = results; _isSearching = false; });
    } catch (e) {
      if (mounted) setState(() { _cityResults = []; _isSearching = false; });
    }
  }

  // Searches for other registered users and loads their friendship statuses.
  Future<void> _searchUsers(String query) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    setState(() => _isSearching = true);
    try {
      final users = await widget.userRepository.searchUsers(query, excludeUid: currentUid);
      final results = <_UserSearchResult>[];
      for (final u in users) {
        final friendship = await widget.friendshipRepository.statusBetween(currentUid, u.uid);
        results.add(_UserSearchResult(user: u, friendship: friendship));
      }
      if (mounted) setState(() { _userResults = results; _isSearching = false; });
    } catch (e) {
      if (mounted) setState(() { _userResults = []; _isSearching = false; });
    }
  }

  void _showCityDetails(CitySearchResult city) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CityDetailsSheet(
        city: city,
        onCityAdded: widget.onCityAdded,
        cityRepository: widget.repository,
        wishlistRepository: widget.wishlistRepository,
      ),
    );
  }

  Widget _buildUserTile(_UserSearchResult result) {
    final theme = Theme.of(context);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final initialLetter = result.user.userName.isNotEmpty ? result.user.userName[0].toUpperCase() : null;

    return Material(
      color: theme.brightness == Brightness.light ? Colors.white : AppColors.surfaceCardDark,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                viewedUid: result.user.uid,
                cityRepository: widget.repository,
                userRepository: widget.userRepository,
                friendshipRepository: widget.friendshipRepository,
                wishlistRepository: widget.wishlistRepository,
                commentRepository: widget.commentRepository,
                onNavigateToStats: () {},
              ),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          child: Text(initialLetter ?? '', style: const TextStyle(fontWeight: FontWeight.bold))
        ),
        title: Text(result.user.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FriendshipActionButton(
              friendship: result.friendship,
              currentUid: currentUid,
              onAdd: () => _sendRequest(result),
              onRespond: (accept) => _respondToRequest(result, accept: accept),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.brightness == Brightness.light
                ? AppColors.textSecondaryLight
                : AppColors.textSecondaryDark,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _sendRequest(_UserSearchResult result) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;
    final friendship = await widget.friendshipRepository.sendRequest(currentUid, result.user.uid);
    setState(() {
      final index = _userResults.indexOf(result);
      if (index != -1) _userResults[index] = _UserSearchResult(user: result.user, friendship: friendship);
    });
  }

  Future<void> _respondToRequest(_UserSearchResult result, {required bool accept}) async {
    final friendship = result.friendship;
    if (friendship == null) return;
    await widget.friendshipRepository.respondToRequest(friendship.id, accept: accept);

    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final updated = accept ? await widget.friendshipRepository.statusBetween(currentUid, result.user.uid) : null;

    setState(() {
      final index = _userResults.indexOf(result);
      if (index != -1) _userResults[index] = _UserSearchResult(user: result.user, friendship: updated);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isUserSearchDisabled = _selectedCategory == SearchCategory.users && !isLoggedIn;
    
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
                        _userResults = [];
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
                  enabled: !isUserSearchDisabled,
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: isUserSearchDisabled
                        ? 'Please log in'
                        : (_selectedCategory == SearchCategory.cities 
                            ? 'Search for a city...' 
                            : 'Search for travelers...'),
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
                    disabledBorder: OutlineInputBorder(
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
      if(FirebaseAuth.instance.currentUser == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 48, color: AppColors.textSecondaryLight),
              const SizedBox(height: 16),
              Text('Join Roamly to find your friends',
                  style: theme.textTheme.bodyLarge),
              TextButton(
                //navigate to log in when logged out
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Log In'),
              ),
            ],
          ),
        );
      }

      final query = _searchController.text.trim();
      if(query.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_alt, size: 64, color: AppColors.primaryOrange.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('Search for a Username',
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondaryLight)),
            ],
          ),
        );
      }

      if (!_isSearching && _userResults.isEmpty) {
        return const Center(child: Text('No users found'));
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _userResults.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildUserTile(_userResults[index]),
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
  final WishlistRepository wishlistRepository;
  final CityRepository cityRepository;
  final VoidCallback onCityAdded;

  const _CityDetailsSheet({
    required this.city,
    required this.wishlistRepository,
    required this.cityRepository,
    required this.onCityAdded,
  });

  @override
  State<_CityDetailsSheet> createState() => _CityDetailsSheetState();
}

class _UserSearchResult {
  final UserModel user;
  final FriendshipModel? friendship;

  const _UserSearchResult({required this.user, this.friendship});
}

class _CityDetailsSheetState extends State<_CityDetailsSheet> {
  //deliberate trade-off: global ratings for each city do not get persisted but get generated again each time it is searched
  //in a real App this would be saved somewhere globally for each user to be identical, here it is only a mocked function
  late final Map<double, int> _ratingDistribution;
  late final double _averageRating;
  final _ratingService = MockCityRatingService();

  WishlistEntry? _wishlistEntry;
  bool _isLoadingWishlistStatus = true;

  @override
  void initState() {
    super.initState();
    // Requirements: generate exactly once and store in local state for the sheet's lifetime
    _ratingDistribution = _ratingService.generateRatingDistribution();
    _averageRating = _ratingService.averageRating(_ratingDistribution);
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final result = await widget.wishlistRepository.isWishlisted(
      user.uid,
      widget.city.name,
      widget.city.latitude,
      widget.city.longitude,
    );
    setState(() {
      _wishlistEntry = result;
      _isLoadingWishlistStatus = false;
    });
  }

  void _logThisCity() {
    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.pop();
    navigator.push(MaterialPageRoute(
      builder: (context) => AddCityPage(
        onSave: widget.onCityAdded,
        repository: widget.cityRepository,
        prefill: widget.city,
      ),
    ));
  }

  // Toggles the city's presence in the user's local SQFlite wishlist.
  Future<void> _toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_wishlistEntry != null) {
      await widget.wishlistRepository.removeFromWishlist(_wishlistEntry!.id, user.uid);
      setState(() => _wishlistEntry = null);
    } else {
      final entry = WishlistEntry(
          id: WishlistEntry.UNSAVED_ID,
          userId: user.uid,
          cityName: widget.city.name,
          country: widget.city.country,
          continent: widget.city.continent,
          latitude: widget.city.latitude,
          longitude: widget.city.longitude,
      );
      final saved = await widget.wishlistRepository.addToWishlist(entry);
      setState(() => _wishlistEntry = saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
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
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.city.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          widget.city.country,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_averageRating.toStringAsFixed(1)} ★',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Container(
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 40,
                    //Tooltips to see the individual percentages for each rating
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor:(group) => isDark ? Colors.transparent : Colors.white,
                        tooltipPadding: EdgeInsets.zero,
                        tooltipMargin: 0,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()}%',
                            TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      )
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= MockCityRatingService.ratingCategories.length) {
                              return const SizedBox.shrink();
                            }
                            final rating = MockCityRatingService.ratingCategories[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                rating.toString(),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(
                      MockCityRatingService.ratingCategories.length,
                      (i) {
                        final rating = MockCityRatingService.ratingCategories[i];
                        final percentage = _ratingDistribution[rating] ?? 0;
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: percentage.toDouble(),
                              color: AppColors.primaryOrange,
                              width: 14,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingWishlistStatus ? null : _toggleWishlist,
                      icon: Icon(
                        _wishlistEntry != null ? Icons.bookmark : Icons.bookmark_outline, 
                        size: 16,
                      ),
                      label: Text(
                        _wishlistEntry != null ? 'Wishlisted' : 'Wishlist',
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        backgroundColor: _wishlistEntry != null
                            ? AppColors.primaryOrange.withValues(alpha: 0.15)
                            : AppColors.primaryOrange,
                        foregroundColor: _wishlistEntry != null 
                            ? AppColors.primaryOrange 
                            : Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _logThisCity,
                      icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                      label: const Text(
                        'Log City',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
