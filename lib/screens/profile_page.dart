import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roamly/screens/stats_page.dart';

import 'package:roamly/services/city_repository.dart';
import 'package:roamly/services/friendship_repository.dart';
import 'package:roamly/services/user_repository.dart';
import 'package:roamly/widgets/city_entry_card.dart';
import '../main.dart';
import '../models/city_entry_model.dart';
import '../models/friendship_model.dart';
import '../models/stats.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/stats_service.dart';
import '../widgets/friendship_action_button.dart';
import '../widgets/stat_chip.dart';
import 'add_city_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final CityRepository cityRepository;
  final UserRepository userRepository;
  final FriendshipRepository friendshipRepository;
  final String viewedUid;
  final VoidCallback onNavigateToStats;

  const ProfilePage({
    super.key,
    required this.cityRepository,
    required this.userRepository,
    required this.friendshipRepository,
    required this.viewedUid,
    required this.onNavigateToStats,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  late TabController _tabController;

  bool get isOwnProfile => FirebaseAuth.instance.currentUser?.uid == widget.viewedUid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: isOwnProfile ? 3 : 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of Roamly?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _authService.signOut();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<User?>(
      stream: _authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) return _buildLoggedOutProfile(theme);

        return Scaffold(
          appBar: AppBar(
            title: Text(isOwnProfile ? 'My Profile' : 'Profile'),
            actions: [
              if (isOwnProfile)
                IconButton(icon: const Icon(Icons.logout),
                    onPressed: _showLogoutConfirmation),
            ],
            bottom: isOwnProfile
                ? TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Friend Requests'),
                Tab(text: 'Settings')
              ],
            )
                : null,
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              if (isOwnProfile) _buildRequestsTab(),
              if (isOwnProfile) _buildSettingsTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoggedOutProfile(ThemeData theme) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore_rounded, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Roamly',
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Log your journey. Explore theirs.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage())
                  ),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final statsService = StatsService(cityRepository: widget.cityRepository);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        widget.cityRepository.getEntries(widget.viewedUid),
        widget.userRepository.getUser(widget.viewedUid),
        statsService.calculateStatsFor(widget.viewedUid),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = (snapshot.data?[0] as List<CityEntry>?) ?? [];
        final userModel = snapshot.data?[1] as UserModel?;
        final stats = snapshot.data?[2] as Stats;
        final userName = userModel?.userName ?? 'Unknown User';

        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 48,
                    child: Icon(Icons.person, size: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(width: 80, child: StatChip(label: 'Cities', value: stats.distinctCities.toString())),
                      SizedBox(width: 80, child: StatChip(label: 'Countries', value: stats.distinctCountries.toString())),
                      SizedBox(width: 80, child: StatChip(label: 'Continents', value: stats.distinctContinents.toString())),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                if (isOwnProfile) {
                  widget.onNavigateToStats();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StatsPage(viewedUid: widget.viewedUid),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text('View Travel Stats'),
            ),
            const SizedBox(height: 24),

            Text('Travel History', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            if (logs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No journeys logged yet.')),
              )
            else
              ...logs.map((log) => CityEntryCard(log: log)),
          ],
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FutureBuilder<List<FriendshipModel>>(
      future: widget.friendshipRepository.pendingReceivedBy(currentUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data ?? [];

        if(requests.isEmpty) {
          return const Center(child: Text('No pending Friend Requests'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final friendRequests = requests[index];

            return FutureBuilder<UserModel?>(
              future: widget.userRepository.getUser(friendRequests.requesterUid),
              builder: (context, userSnapshot) {
                final requester = userSnapshot.data?.userName ?? 'Unknown User';

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(requester),
                  subtitle: const Text('Sent you a friend request'),
                  trailing: FriendshipActionButton(
                    friendship: friendRequests,
                    currentUid: currentUid,
                    onAdd: () {},
                    onRespond: (accept) async {
                      await widget.friendshipRepository.respondToRequest(
                        friendRequests.id,
                        accept: accept,
                      );
                      setState(() {});
                    },
                  ),
                );
              }
            );
          }
        );
      }
    );
  }

  Widget _buildSettingsTab() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FutureBuilder<List<CityEntry>>(
      future: widget.cityRepository.getEntries(currentUid),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: themeNotifier.value == ThemeMode.dark,
                onChanged: (bool value) {
                  setState(() {
                    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                  });
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),

            Text('Manage Trips', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),

            if (logs.isEmpty)
            const Center(child: Text('No trips to manage.'))
            else
              ...logs.map((log) => ListTile(
                title: Text(log.name),
                subtitle: Text(log.country),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCityPage(
                            onSave: () => setState(() {}),
                            repository: widget.cityRepository,
                            editingEntry: log, // This triggers the edit mode logic
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () async {
                        await widget.cityRepository.deleteEntry(log.id, currentUid);
                        setState(() {});
                      },
                    ),
                  ],
                )
              ),
            )
          ],
        );
      }
    );
  }
}
