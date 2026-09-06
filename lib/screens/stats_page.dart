import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: const Center(
        child: Text('here you will be able to see your lifetime stats and spots of the world you already visited'),
      ),
    );
  }
}