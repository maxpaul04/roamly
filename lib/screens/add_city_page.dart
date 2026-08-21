import 'package:flutter/material.dart';
import 'package:roamly/services/city_repository.dart';
import '../models/city_entry_model.dart';
import '../themes/colors.dart';

class AddCityPage extends StatefulWidget {
  final VoidCallback onSave;
  final CityRepository repository;

  const AddCityPage({
    super.key,
    required this.onSave,
    required this.repository
  });

  @override
  State<AddCityPage> createState() => _AddCityPageState();
}

class _AddCityPageState extends State<AddCityPage> {
  final _cityNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _commentController = TextEditingController();
  double _selectedRating = 5.0;

  @override
  void dispose() {
    _cityNameController.dispose();
    _countryController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_cityNameController.text.trim().isEmpty) return;

    final newCity = CityEntry(
      id: CityEntry.UNSAVED_ID,
      userId: '1', 
      name: _cityNameController.text.trim(),
      country: _countryController.text.trim(),
      arrivalDate: DateTime.now(),
      departureDate: DateTime.now(),
      rating: _selectedRating,
      comment: _commentController.text.trim(),
    );

    await widget.repository.addEntry(newCity);
    widget.onSave();
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
            Text('Add a city you have visited',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),

            TextFormField(
              controller: _cityNameController,
              decoration: const InputDecoration(
                labelText: 'City Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Review Comment',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Letterboxd-style Rating Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rating', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${_selectedRating.toStringAsFixed(1)} ★',
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final double starValue = index + 1.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Stack(
                      children: [
                        Icon(
                          _selectedRating >= starValue
                              ? Icons.star
                              : (_selectedRating >= starValue - 0.5
                                  ? Icons.star_half
                                  : Icons.star_outline),
                          color: _selectedRating >= starValue - 0.5
                              ? AppColors.primaryOrange
                              : Colors.grey.withValues(alpha: 0.3),
                          size: 48,
                        ),
                        Positioned.fill(
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => _selectedRating = starValue - 0.5),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => _selectedRating = starValue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveEntry,
                child: const Text('Save Journey'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
