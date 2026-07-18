import 'package:flutter/material.dart';

class AddCityPage extends StatelessWidget {
  const AddCityPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add City'),
      ),
      body: const Center(
        child: Text('here you will be able to add and document new cities and trips'),
      ),
    );
  }
}