import 'package:flutter/material.dart';
import 'package:roamly/services/sqflite_city_repository.dart';
import 'package:roamly/themes/colors.dart';
import '../models/stats.dart';
import '../services/stats_service.dart';

class StatsPage extends StatefulWidget {
  final String viewedUid;

  const StatsPage ({super.key, required this.viewedUid});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Stats? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cityRepo = SqfliteCityRepository();
    final stats = await StatsService(cityRepository: cityRepo).calculateStatsFor(widget.viewedUid);
    setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Stats'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _stats == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Stats
            _buildHeroStats(_stats!),
            const SizedBox(height: 32),

            // Map Placeholder
            SizedBox(
              height: 220,
              width: double.infinity,

              child: const Center(
                child: Icon(Icons.map_outlined, size: 48, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),

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