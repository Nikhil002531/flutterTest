import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class DisasterReport {
  final String? id;
  final double? lat;
  final double? lng;
  final double? severity;
  final String? urgency;
  final String? disasterType;
  final String? locationName;
  final DateTime? timestamp;

  final String? userId;
  final String? description;
  final String? imagePath;

  DisasterReport({
    this.id,
    this.lat,
    this.lng,
    this.severity,
    this.urgency,
    this.disasterType,
    this.locationName,
    this.timestamp,
    this.userId,
    this.description,
    this.imagePath,
  });

  factory DisasterReport.fromJson(Map<String, dynamic> json) {
    return DisasterReport(
      id: json["id"],
      lat: json["lat"]?.toDouble(),
      lng: json["lng"]?.toDouble(),
      severity: json["severity"]?.toDouble(),
      urgency: json["urgency"],
      disasterType: json["disaster_type"],
      locationName: json["location_name"],
      timestamp: json["timestamp"] != null
          ? DateTime.parse(json["timestamp"])
          : null,
    );
  }

  Map<String, String> toUploadJson() {
    return {
      "userId": userId ?? "",
      "lat": lat?.toString() ?? "",
      "lng": lng?.toString() ?? "",
      "location_name": locationName ?? "",
      "timestamp": timestamp?.toIso8601String() ?? "",
      "disaster_type": disasterType ?? "",
      "description": description ?? "",
    };
  }

  Future<void> sendToBackend() async {
    if (imagePath == null) throw Exception("No image provided");

    final url = Uri.parse("https://three9-analysis.onrender.com/upload");
    var request = http.MultipartRequest("POST", url);

    request.fields.addAll(toUploadJson());
    request.files.add(await http.MultipartFile.fromPath("image", imagePath!));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception("Upload failed: ${response.statusCode}");
    }
  }
}
