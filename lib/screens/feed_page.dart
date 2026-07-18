import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  const FeedPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('roamly'),
      ),
      body: const Center(
          child: Text('here you will see your homepage'),
      ),
    );
  }
}