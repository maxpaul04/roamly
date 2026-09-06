import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/city_entry_model.dart';
import '../themes/colors.dart';

class CityEntryCard extends StatelessWidget {
  final CityEntry log;

  const CityEntryCard({super.key, required this.log});

  String _formatDateRange(DateTime start, DateTime end) {
    final DateFormat monthYear = DateFormat('MMM yyyy');
    final DateFormat monthOnly = DateFormat('MMM');

    if (start.year != end.year) {
      return '${monthYear.format(start)} — ${monthYear.format(end)}';
    } else if (start.month != end.month) {
      return '${monthOnly.format(start)} — ${monthYear.format(end)}';
    } else {
      return monthYear.format(start);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF242438), // Roamly card surface
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.name,
                        style: const TextStyle(
                          color: Color(0xFFF5F0EB),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${log.userName}',
                        style: const TextStyle(
                          color: Color(0xFF7A6F65),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${log.rating.toStringAsFixed(1)} ★',
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // Slightly bigger rating
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${log.country} (${log.continent})',
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  ' • ',
                  style: TextStyle(color: Color(0xFF7A6F65)),
                ),
                Text(
                  _formatDateRange(log.arrivalDate, log.departureDate),
                  style: const TextStyle(
                    color: Color(0xFF7A6F65),
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            if (log.imagePath != null && log.imagePath!.isNotEmpty) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(log.imagePath!),
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
            
            if (log.comment != null && log.comment!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                log.comment!,
                style: const TextStyle(
                  color: Color(0xFFF5F0EB),
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
