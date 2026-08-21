import 'package:flutter/material.dart';
import 'package:roamly/services/city_repository.dart';
import '../models/city_entry_model.dart';
import '../services/sqflite_city_repository.dart';
import '../widgets/city_entry_card.dart';

class FeedPage extends StatefulWidget {
  final int reloadTrigger;
  final CityRepository repository;

  const FeedPage({
    super.key,
    required this.reloadTrigger,
    required this.repository,
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _repository = SqfliteCityRepository();
  List<CityEntry> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(FeedPage old) {
    super.didUpdateWidget(old);
    if (old.reloadTrigger != widget.reloadTrigger) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final data = await _repository.getEntries('1');
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
