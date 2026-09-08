import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:roamly/services/city_repository.dart';
import '../models/city_entry_model.dart';
import '../services/city_api_service.dart';
import '../services/image_storage_service.dart';
import '../themes/colors.dart';
import 'login_page.dart';

class AddCityPage extends StatefulWidget {
  final VoidCallback onSave;
  final CityRepository repository;
  final CitySearchResult? prefill;
  final CityEntry? editingEntry;

  const AddCityPage({
    super.key,
    required this.onSave,
    required this.repository,
    this.prefill,
    this.editingEntry,
  });

  @override
  State<AddCityPage> createState() => _AddCityPageState();
}

class _AddCityPageState extends State<AddCityPage> {
  final _cityNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _commentController = TextEditingController();
  final CityApiService apiService = CityApiService();

  List<CitySearchResult> results = [];
  CitySearchResult? selectedResult;
  Timer? _debounce;
  bool _isSearching = false;

  double _selectedRating = 5.0;
  File? _pickedImage;

  DateTime? _arrivalDate;
  DateTime? _departureDate;
  String? _dateError;
  String? nameError;
  String? countryError;

  @override
  void initState() {  
    super.initState();

    //prefill selection for existing entries when coming from editing mode
    if(widget.editingEntry != null) {
      final entry = widget.editingEntry!;
      _cityNameController.text = entry.name;
      _countryController.text = entry.country;
      _arrivalDate = entry.arrivalDate;
      _departureDate = entry.departureDate;
      _commentController.text = entry.comment!;
      _selectedRating = entry.rating;
    }
    else if (widget.prefill != null) {
      final prefill = widget.prefill!;
      selectedResult = prefill;
      _cityNameController.text = prefill.name;
      _countryController.text = prefill.country;
    }
  }
  
  @override
  void dispose() {
    _cityNameController.dispose();
    _countryController.dispose();
    _commentController.dispose();
    _debounce?.cancel();
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
        if (_departureDate?.isBefore(picked) ?? false) {
          _departureDate = null;
        }
      } else {
        _departureDate = picked;
      }
      _dateError = null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = _cityNameController.text.trim();

    setState(() {
      nameError = null;
      countryError = null;
      _dateError = null;
    });

    bool hasErrors = false;
    if (selectedResult == null) {
      nameError = 'Please select a city from the list';
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
    //only requires a city selection when creating a new entry, not editing
    if (selectedResult == null && widget.editingEntry == null) {
      nameError = 'Please select a city from the list';
      hasErrors = true;
    }

    if (hasErrors) return;

    String? imagePath = widget.editingEntry?.imagePath;
    if (_pickedImage != null) {
      imagePath = await ImageStorageService().saveImage(_pickedImage!);
    }

    final newCity = CityEntry(
      id: widget.editingEntry?.id ?? CityEntry.UNSAVED_ID,
      userId: user.uid,
      userName: user.displayName ?? 'Traveler',
      name: name,
      country: widget.editingEntry?.country ?? selectedResult!.country,
      continent: widget.editingEntry?.continent ?? selectedResult!.continent,
      arrivalDate: _arrivalDate!,
      departureDate: _departureDate!,
      rating: _selectedRating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
      latitude: selectedResult!.latitude,
      longitude: selectedResult!.longitude,
      imagePath: imagePath,
    );

    if (widget.editingEntry != null) {
      await widget.repository.updateEntry(newCity);
    } else {
      await widget.repository.addEntry(newCity);
    }
    widget.onSave();

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  //Code for this method generated with help from AI --> resets search on every keystroke with a small delay not to immediately search and burn API-calls
  void _whenCitySearchChanged(String query) async {
    _debounce?.cancel();
    setState(() {
      selectedResult = null;
      results = []; // Clear results while typing new query
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().length < 2) {
        setState(() {
          results = [];
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);
      
      try {
        final fetchedResults = await apiService.searchCities(query);
        setState(() {
          results = fetchedResults;
          _isSearching = false;
        });
      } catch (e) {
        setState(() {
          results = [];
          _isSearching = false;
        });
      }
    });
  }

  void _onCitySelected(CitySearchResult result) {
    setState(() {
      selectedResult = result;
      _cityNameController.text = result.name;
      _countryController.text = result.country;
      results = [];
    });
    FocusScope.of(context).unfocus(); // Close keyboard after selection
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Add City')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sign In Required',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You need to be logged in to log your travels.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                        if (mounted) setState(() {});
                      },
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Add City'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Share your Trip',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityNameController,
                  decoration: const InputDecoration(
                    labelText: 'City Name*',
                    border: OutlineInputBorder(),
                    hintText: 'Start typing to search...',
                  ),
                  onChanged: _whenCitySearchChanged,
                ),
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: LinearProgressIndicator()),
                  ),
                if (results.isNotEmpty)
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(top: 4),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final city = results[index];
                          return ListTile(
                            title: Text(city.name),
                            subtitle: Text(city.country),
                            onTap: () => _onCitySelected(city),
                          );
                        },
                      ),
                    ),
                  ),
                if (nameError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(nameError!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _countryController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Country (auto-filled)*',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.1),
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
                  Text(_dateError!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Review Comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 160),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCardDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _pickedImage != null
                        ? Image.file(
                            _pickedImage!,
                            fit: BoxFit.fitWidth,
                          )
                        : const SizedBox(
                            height: 160,
                            child: Center(
                              child: Icon(
                                Icons.add_a_photo_outlined,
                                color: AppColors.textSecondaryLight,
                                size: 32,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
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
      },
    );
  }
}
