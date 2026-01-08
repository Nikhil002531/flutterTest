import 'package:flutter/material.dart';
import '../models/disaster_report.dart';

void showDetailBottomSheet(BuildContext context, DisasterReport report) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                report.disasterType ?? "Unknown Disaster",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 10),

              _info("Description", report.description ?? "No description"),
              _info("Location", report.locationName ?? "Unknown"),
              _info("Latitude", "${report.lat ?? 0}"),
              _info("Longitude", "${report.lng ?? 0}"),
              _info("Severity", "${report.severity ?? 0}"),
              _info("Urgency", report.urgency ?? "N/A"),
              _info("Time", report.timestamp?.toString() ?? "Unknown"),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}

Widget _info(String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.label_important, color: Colors.deepPurple, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$title: $value",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
