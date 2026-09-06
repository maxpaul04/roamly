import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:roamly/services/city_repository.dart';
import 'package:roamly/services/friendship_repository.dart';
import 'package:roamly/services/user_repository.dart';
import 'package:roamly/widgets/city_entry_card.dart';
import '../models/city_entry_model.dart';
import '../models/friendship_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/friendship_action_button.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final CityRepository cityRepository;
  final UserRepository userRepository;
  final FriendshipRepository friendshipRepository;
  final String viewedUid;

  const ProfilePage({
    super.key,
    required this.cityRepository,
    required this.userRepository,
    required this.friendshipRepository,
    required this.viewedUid,
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
    return FutureBuilder<List<CityEntry>>(
      future: widget.cityRepository.getEntries(widget.viewedUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = snapshot.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/stats', arguments: widget.viewedUid),
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
    return Scaffold(
      //TODO
    );
  }
}
