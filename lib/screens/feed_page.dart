import 'package:flutter/material.dart';
import '../models/city_entry_model.dart';
import '../services/city_repository.dart';
import '../themes/colors.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('roamly'),
      ),
      body: FutureBuilder<List<CityEntry>>(
        future: CityRepository().getAllCityEntries(),
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                title: Text(log.name),
                subtitle: Text(log.comment),
                trailing: Text(
                  '${log.rating} ★',
                  style: const TextStyle(color: AppColors.primaryOrange),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
