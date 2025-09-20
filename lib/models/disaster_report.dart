// lib/models/disaster_report.dart
import 'package:latlong2/latlong.dart';

class DisasterReport {
  final String imagePath;
  final double? latitude;
  final double? longitude;
  final String location;
  final String timestamp;
  final String disasterType;
  final String description;
  final double intensity; // heatmap weight

  DisasterReport({
    required this.imagePath,
    this.latitude,
    this.longitude,
    required this.location,
    required this.timestamp,
    required this.disasterType,
    required this.description,
    this.intensity = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      "image_path": imagePath,
      "latitude": latitude,
      "longitude": longitude,
      "location": location,
      "timestamp": timestamp,
      "disasterType": disasterType,
      "description": description,
      "intensity": intensity,
    };
  }

  /// Build from a scraped post (the JSON you uploaded).
  factory DisasterReport.fromScraperMap(Map<String, dynamic> m) {
    double? lat;
    double? lon;

    // 1) If post contains a location object with lat/lon
    if (m['location'] is Map) {
      final loc = m['location'] as Map;
      if (loc['latitude'] != null && loc['longitude'] != null) {
        lat = (loc['latitude'] as num).toDouble();
        lon = (loc['longitude'] as num).toDouble();
      }
    }

    // 2) If scraper stored lat/lon directly
    if (lat == null && m['latitude'] != null && m['longitude'] != null) {
      lat = (m['latitude'] as num).toDouble();
      lon = (m['longitude'] as num).toDouble();
    }

    // 3) fallback: quick city keyword -> coords mapping
    if (lat == null) {
      final text = ((m['cleaned_text'] ?? m['raw_text'] ?? '') as String).toLowerCase();
      for (final e in _cityCoords.entries) {
        if (text.contains(e.key)) {
          lat = e.value.latitude;
          lon = e.value.longitude;
          break;
        }
      }
    }

    // 4) image: choose first media if any
    String image = '';
    if (m['media_urls'] is List && (m['media_urls'] as List).isNotEmpty) {
      image = (m['media_urls'] as List).first as String;
    }

    final dtype = (m['ai_classification']?['category'] ?? m['metadata']?['category'] ?? m['disasterType'] ?? 'Unknown').toString();

    // 5) intensity: prefer AI urgency, else boring engagement heuristic
    double intensity = 1.0;
    if (m['ai_classification']?['urgency'] != null) {
      final urgency = m['ai_classification']['urgency'].toString().toLowerCase();
      if (urgency.contains('critical')) intensity = 4.0;
      else if (urgency.contains('high')) intensity = 3.0;
      else if (urgency.contains('medium')) intensity = 2.0;
      else intensity = 1.0;
    } else if (m['engagement'] != null) {
      final likes = (m['engagement']['likes'] ?? 0) as num;
      intensity = 1.0 + (likes.toDouble() / 100.0);
      if (intensity > 5.0) intensity = 5.0;
    }

    return DisasterReport(
      imagePath: image,
      latitude: lat,
      longitude: lon,
      location: (m['location'] is String ? m['location'] as String : (m['location']?['name'] ?? 'Unknown')).toString(),
      timestamp: (m['timestamp'] ?? '').toString(),
      disasterType: dtype,
      description: (m['cleaned_text'] ?? m['raw_text'] ?? '').toString(),
      intensity: intensity,
    );
  }
}

const Map<String, LatLng> _cityCoords = {
  'mumbai': LatLng(19.0760, 72.8777),
  'bombay': LatLng(19.0760, 72.8777),
  'delhi': LatLng(28.6139, 77.2090),
  'chennai': LatLng(13.0827, 80.2707),
  'kolkata': LatLng(22.5726, 88.3639),
  'bangalore': LatLng(12.9716, 77.5946),
  'bengaluru': LatLng(12.9716, 77.5946),
  'vizag': LatLng(17.6868, 83.2185),
  'visakhapatnam': LatLng(17.6868, 83.2185),
  'kochi': LatLng(9.9312, 76.2673),
};
