import 'package:flutter/material.dart';
import '../models/city_entry_model.dart';
import '../services/city_repository.dart';
import '../widgets/city_entry_card.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<CityEntry> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await CityRepository().getAllCityEntries();
    setState(() {
      _logs = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('roamly'),
      ),
      body: ListView(
        children: [
          for (final log in _logs)
            CityEntryCard(log: log),
        ],
      ),
    );
  }
}
