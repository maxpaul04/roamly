import 'package:flutter/material.dart';
import '../models/city_entry_model.dart';

class AddCityPage extends StatefulWidget {

  final Function(CityEntry) onSave;
  const AddCityPage({super.key, required this.onSave});

  @override
  State<AddCityPage> createState() => _AddCityPageState();
  }

class _AddCityPageState extends State<AddCityPage> {
  final _cityNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _commentController = TextEditingController();
  final _ratingController = TextEditingController();

  @override
  void dispose() {
    _cityNameController.dispose();
    _countryController.dispose();
    _commentController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

    void _saveEntry() {
      final double rating = double.tryParse(_ratingController.text) ?? 0.0;

      final newCity = CityEntry(
      id: 1,
      name: _cityNameController.text,
      country: _countryController.text,
      arrivalDate: DateTime.now(),
      departureDate: DateTime.now(),
      rating: rating,
      comment: _commentController.text,
      );

      widget.onSave(newCity);
  }

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
              controller: _cityNameController,
              decoration: const InputDecoration(
                labelText: 'City Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            //Input form for the country
            TextFormField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            //Input form for the review comment
            TextFormField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Review Comment',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _ratingController,
              decoration: InputDecoration(
                labelText: 'Rating (1.0-5.0)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            //Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  print('Button pressed (debug)');
                  _saveEntry();
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
