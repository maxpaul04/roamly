import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roamly/services/city_repository.dart';
import 'package:roamly/services/comment_repository.dart';
import 'package:roamly/services/friendship_repository.dart';
import 'package:roamly/services/sqflite_city_repository.dart';
import 'package:roamly/services/sqflite_comment_repository.dart';
import 'package:roamly/services/sqflite_friendship_repository.dart';
import 'package:roamly/services/sqflite_user_repository.dart';
import 'package:roamly/services/sqflite_wishlist_repository.dart';
import 'package:roamly/services/user_repository.dart';
import 'package:roamly/services/wishlist_repository.dart';
import 'screens/feed_page.dart';
import 'screens/add_city_page.dart';
import 'screens/stats_page.dart';
import 'screens/profile_page.dart';
import 'screens/search_page.dart';

class MainNavigation extends StatefulWidget{
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
  }

class _MainNavigationState extends State<MainNavigation>{
  int _selectedIndex = 0;
  int _reloadTrigger = 0;

  final CityRepository _repository = SqfliteCityRepository();
  final UserRepository _userRepository = SqfliteUserRepository();
  final FriendshipRepository _friendshipRepository = SqfliteFriendshipRepository();
  final WishlistRepository _wishlistRepository = SqfliteWishlistRepository();
  final CommentRepository _commentRepository = SqfliteCommentRepository();

  void _handleCityAdded() {
    setState(() {
      _reloadTrigger++;
      _selectedIndex = 0; // Go back to feed page when adding a city
    });
  }

  void _goToTab(int index) => setState(()
    => _selectedIndex = index
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final currentUid = snapshot.data?.uid ?? '';

        final List<Widget> pages = [
          FeedPage(
            reloadTrigger: _reloadTrigger,
            cityRepository: _repository,
            commentRepository: _commentRepository,
          ),
          SearchPage(
            repository: _repository,
            onCityAdded: _handleCityAdded,
            userRepository: _userRepository,
            friendshipRepository: _friendshipRepository,
            wishlistRepository: _wishlistRepository,),
          AddCityPage(
              onSave: _handleCityAdded,
              repository: _repository),
          StatsPage(viewedUid: currentUid,),
          ProfilePage(
              cityRepository: _repository,
              userRepository: _userRepository,
              friendshipRepository: _friendshipRepository,
              wishlistRepository: _wishlistRepository,
              viewedUid: currentUid,
              onNavigateToStats: () => _goToTab(3)),
        ];

        return Scaffold(
            body: pages[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Feed',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline),
                  selectedIcon: Icon(Icons.add_circle),
                  label: 'Add City',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart_outlined),
                  label: 'Stats',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
        );
      },
    );
  }
}
