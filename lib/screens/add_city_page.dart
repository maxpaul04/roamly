import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  DateTime? _arrivalDate;
  DateTime? _departureDate;
  String? _dateError;
  String? nameError;
  String? countryError;

  @override
  void dispose() {
    _cityNameController.dispose();
    _countryController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isArrival}) async {
    final now = DateTime.now();
    final initialDate = isArrival 
        ? (_arrivalDate ?? now) 
        : (_departureDate ?? _arrivalDate ?? now);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
    );
    
    if (picked == null) return;
    
    setState(() {
      if (isArrival) {
        _arrivalDate = picked;
        // Reset departure if it conflicts with the new arrival date
        if (_departureDate?.isBefore(picked) ?? false) {
          _departureDate = null;
        }
      } else {
        _departureDate = picked;
      }
      _dateError = null;
    });
  }

  Future<void> _saveEntry() async {
    final name = _cityNameController.text.trim();
    final country = _countryController.text.trim();

    setState(() {
      nameError = null;
      countryError = null;
      _dateError = null;
    });

    bool hasErrors = false;

    if (name.isEmpty) {
      nameError = 'Please enter a city name';
      hasErrors = true;
    }

    if (country.isEmpty) {
      countryError = 'Please enter a country';
      hasErrors = true;
    }

    if (_arrivalDate == null || _departureDate == null) {
      _dateError = 'Please select your visit dates';
      hasErrors = true;
    }

    if (_departureDate != null && _departureDate!.isBefore(_arrivalDate!)) {
      _dateError = 'Departure date cannot be before arrival date';
      hasErrors = true;
    }

    if (hasErrors) {
      return;
    }

    final newCity = CityEntry(
      id: CityEntry.UNSAVED_ID,
      userId: '1', 
      name: _cityNameController.text.trim(),
      country: _countryController.text.trim(),
      arrivalDate: _arrivalDate!,
      departureDate: _departureDate!,
      rating: _selectedRating,
      comment: _commentController.text.trim(),
    );

    await widget.repository.addEntry(newCity);
    widget.onSave();
  }

  Widget _buildDateInput({
    required DateTime? date,
    required String label,
    required Future<void> Function() onTap,
}) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null ? DateFormat('dd.MM.yyyy').format(date) : 'Select Date',
        ),
      ),
    );
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
                labelText: 'City Name*',
                border: OutlineInputBorder(),
              ),
            ),
            if (nameError != null)
              Text(nameError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),

            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Country*',
                border: OutlineInputBorder(),
              ),
            ),
            if (countryError != null)
              Text(countryError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,

              children: [
                Expanded(
                  child: _buildDateInput(
                      date: _arrivalDate,
                      label: 'Arrival Date*',
                      onTap: () => _pickDate(isArrival: true)
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateInput(
                      date: _departureDate,
                      label: 'Departure Date*',
                      onTap: () => _pickDate(isArrival: false)
                  ),
                ),
              ],
            ),
            if (_dateError != null)
              Text(
                _dateError!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),


            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Review Comment (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            //Star-Rating Selection with help from AI
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
