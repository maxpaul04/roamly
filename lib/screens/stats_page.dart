import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:roamly/models/wishlist_entry_model.dart';
import 'package:roamly/services/sqflite_city_repository.dart';
import 'package:roamly/themes/colors.dart';
import '../models/city_entry_model.dart';
import '../models/stats.dart';
import '../services/sqflite_wishlist_repository.dart';
import '../services/stats_service.dart';

class StatsPage extends StatefulWidget {
  final String viewedUid;

  const StatsPage ({super.key, required this.viewedUid});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Stats? _stats;
  List<CityEntry> _entries = [];

  List<WishlistEntry> _wishlistEntries = [];
  bool _showWishlist = false;

  List<CityEntry?> _myEntries = [];
  bool _showMyEntries = false;
  String? _currentUid;
  bool get _isOwnProfile => _currentUid == null && _currentUid == widget.viewedUid;


  @override
  void initState() {
    super.initState();
    _currentUid = FirebaseAuth.instance.currentUser?.uid;
    _load();
  }

  Future<void> _load() async {
    final cityRepo = SqfliteCityRepository();
    final entries = await cityRepo.getEntries(widget.viewedUid);
    final stats = await StatsService(cityRepository: cityRepo).calculateStatsFor(widget.viewedUid);

    final wishlistRepo = SqfliteWishlistRepository();
    final wishlistEntries = await wishlistRepo.getWishlist(widget.viewedUid);

    final myEntries = (!_isOwnProfile && _currentUid != null)
      ? await cityRepo.getEntries(_currentUid!)
      : <CityEntry>[];

    setState(() {
      _entries = entries;
      _stats = stats;
      _wishlistEntries = wishlistEntries;
      _myEntries = myEntries;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showLoggedOutNotice = _currentUid == null && widget.viewedUid.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Stats'),
        centerTitle: true,
        elevation: 0,
        actions: showLoggedOutNotice
          ? []
          : _isOwnProfile
          ? [IconButton(
            icon: Icon(
              //if on your own profile, gives the choice to overlay your wishlisted cities
              _showWishlist ? Icons.layers : Icons.layers_outlined,
              color: _showWishlist ? Colors.blue : null,
            ),
            tooltip: 'Overlay my Wishlist',
            onPressed: () => setState(() => _showWishlist = !_showWishlist),
            )]
          : [IconButton(
            icon: Icon(
              //if on another users stat-page, gives the choice to overlay your own trips
              _showMyEntries ? Icons.layers : Icons.layers_outlined,
              color: _showMyEntries ? Colors.green : null,
          ),
            tooltip: 'Overlay my Pins',
            onPressed: () => setState(() => _showMyEntries = !_showMyEntries),
            )],
      ),

      body: showLoggedOutNotice
          ? const _LoggedOutStatsNotice()
          : _stats == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Stats
            _buildHeroStats(_stats!),
            const SizedBox(height: 32),

            // Map
            _buildMap(),
            const SizedBox(height: 10),
            Row(
              children: [
                if (!_isOwnProfile && _showMyEntries) ...[
                  const SizedBox(width: 8),
                  _LegendDot(color: AppColors.primaryOrange, label: 'Them'),
                ],
                if (!_isOwnProfile && _showMyEntries) ...[
                  const SizedBox(width: 12),
                  _LegendDot(color: Colors.green, label: 'Me'),
                ],
                const SizedBox(width: 16),
                //Filter to show also wishlisted cities
                if (_isOwnProfile)
                  FilterChip(
                    label: const Text('Wishlist'),
                    selected: _showWishlist,
                    onSelected: (v) => setState(() => _showWishlist = v),
                    avatar: Icon(
                      Icons.bookmark_outline,
                      size: 16,
                      color: _showWishlist ? Colors.white : Colors.blue,
                    ),
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                        color: _showWishlist ? Colors.white : null),
                  ),

                //Filter to overlay your trips on another persons map
                if(!_isOwnProfile)
                FilterChip(
                  label: const Text('Your Trips'),
                  selected: _showMyEntries,
                  onSelected: (v) => setState(() => _showMyEntries = v),
                  avatar: Icon(
                    Icons.location_pin,
                    size: 16,
                    color: _showMyEntries ? Colors.white : Colors.blue,
                  ),
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(color: _showMyEntries ? AppColors.textPrimaryDark : null),
                ),
              ],
            ),

            // Detailed Stats Grid (Bottom)
            const SizedBox(height: 16),
            _buildStatsGrid(_stats!),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStats(Stats stats) {
    return Row(
      children: [
        Expanded(
          child: _HeroStat(label: 'Cities', value: stats.distinctCities.toString()),
        ),
        Expanded(
          child: _HeroStat(label: 'Countries', value: stats.distinctCountries.toString()),
        ),
        Expanded(
          child: _HeroStat(label: 'Continents', value: stats.distinctContinents.toString()),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 260,
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(51, 10),
            initialZoom: 1.5,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.doubleTapZoom
            )
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.roamly.app',
            ),
            MarkerLayer(
              markers: _entries.map((entry) => Marker(
                point: LatLng(entry.latitude, entry.longitude),
                width: 30,
                height: 30,
                child: GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${entry.name} - ${entry.rating.toStringAsFixed(1)} ★'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    )
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primaryOrange,
                    size: 30,
                    ),
                  ),
                )
              ).toList(),
            ),
          if (!_isOwnProfile && _showMyEntries)
          MarkerLayer(
            markers: _myEntries.map((entry) => Marker(
              point: LatLng(entry!.latitude, entry.longitude),
              width: 30,
              height: 30,
              child: GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${entry.name} - ${entry.rating.toStringAsFixed(1)} ★'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                    ),
                  ),
                ),
                child: const Icon(Icons.location_pin, color: Colors.green),
              ),
            )).toList(),
            ),
          //condition rendering for pins of wishlisted cities
          if (_showWishlist)
            MarkerLayer(
              markers: _wishlistEntries.map((w) => Marker(
                point: LatLng(w.latitude, w.longitude),
                width: 30,
                height: 30,
                child: GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${w.cityName}  •  Wishlist'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                  child: const Icon(Icons.bookmark, color: Colors.blue, size: 30),
                ),
              )).toList(),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildStatsGrid(Stats stats) {
    final secondaryStats = [
      _StatTile(label: 'Avg Rating', value: stats.averageRating > 0 ? stats.averageRating.toStringAsFixed(1) : '-', icon: Icons.star_outline),
      _StatTile(label: 'Avg Trip', value: '${stats.averageTripDuration.toStringAsFixed(0)}d', icon: Icons.timelapse_outlined),
      _StatTile(label: 'Total Days', value: stats.totalDaysTravelled.toString(), icon: Icons.calendar_today_outlined),
      _StatTile(label: 'Top Country', value: stats.topCountry, icon: Icons.celebration_outlined),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: secondaryStats,
    );
  }
}

//defines the stat tiles shown above the map
class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

//defines the stats tiles shown below the map
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryOrange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//defines the legend for the map
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

//Notice styled when logged out prompting the user to log in to see their stats
class _LoggedOutStatsNotice extends StatelessWidget {
  const _LoggedOutStatsNotice();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_outlined, size: 48, color: AppColors.primaryOrange),
            const SizedBox(height: 16),
            Text(
              'Log in to see your stats',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}