import 'package:flutter/material.dart';
import '../models/disaster_report.dart';

void showDetailBottomSheet(BuildContext context, DisasterReport r) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              r.disasterType ?? "",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 8),
            Text("Location: ${r.locationName ?? ''}"),
            Text("Urgency: ${r.urgency ?? ''}"),
            Text("Severity: ${r.severity ?? 0}"),
            Text("Time: ${r.timestamp ?? ''}"),
          ],
        ),
      );
    },
  );
}
