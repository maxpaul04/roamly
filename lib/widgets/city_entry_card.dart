import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/city_entry_model.dart';
import '../themes/colors.dart';

class CityEntryCard extends StatelessWidget {
  final CityEntry log;

  const CityEntryCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    log.name,
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${log.rating.toStringAsFixed(1)} ★',
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            // Subtitle Row: Country and Date
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  log.country,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: AppColors.primaryOrange, // Accent color for location
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(' • '),
                Text(
                  DateFormat('MMM yyyy').format(log.arrivalDate),
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
            
            const Divider(height: 24),
            Text(
              log.comment ?? "No comment yet",
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
