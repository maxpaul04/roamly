import 'package:flutter/material.dart';
import 'package:roamly/services/city_repository.dart';
import 'package:roamly/services/sqflite_city_repository.dart';
import 'screens/feed_page.dart';
import 'screens/add_city_page.dart';
import 'screens/notifications_page.dart';
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

  void _handleCityAdded() {
    setState(() {
      _reloadTrigger++;
      _selectedIndex = 0; // Go back to feed page when adding a city
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      FeedPage(reloadTrigger: _reloadTrigger, repository: _repository),
      SearchPage(repository: _repository, onCityAdded: _handleCityAdded,),
      AddCityPage(onSave: _handleCityAdded, repository: _repository),
      const NotificationsPage(),
      ProfilePage(repository: _repository, reloadTrigger: _reloadTrigger),
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
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
