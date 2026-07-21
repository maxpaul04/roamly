import 'package:flutter/material.dart';

class AddCityPage extends StatelessWidget {
  const AddCityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add City'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add a city you have visited', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),

            //Input Form for the city entry
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'City Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            //Input form for the country
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            //Input form for the review comment
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Review Comment',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            //TODO Input form for the rating --> only accept from 1-5 in 0.5 increments

            //Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  print('Button pressed (debug)');
                },
                child: const Text('Save Journey'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
