import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  final String viewedUid;

  const StatsPage ({super.key, required this.viewedUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
      ),
      body: const Center(
        child: Text('here you will be able to see your lifetime stats and spots of the world you already visited'),
      ),
    );
  }
}