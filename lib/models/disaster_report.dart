import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
      description: json["description"],
      userId: json["user_id"],
    );
  }

  Map<String, String> toUploadJson() {
    // Format timestamp as "yyyy-MM-dd HH:mm:ss" for backend
    String formattedTimestamp = "";
    if (timestamp != null) {
      formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp!);
    }
    
    return {
      "user_id": userId ?? "",
      "latitude": lat?.toString() ?? "",
      "longitude": lng?.toString() ?? "",
      "location": locationName ?? "",
      "timestamp": formattedTimestamp,
      "disaster_type": disasterType ?? "",
      "description": description ?? "",
    };
  }

  Future<void> sendToBackend() async {
    if (imagePath == null) throw Exception("No image provided");

    final url = Uri.parse("https://three9-analysis.onrender.com/analyze-report");
    var request = http.MultipartRequest("POST", url);

    request.fields.addAll(toUploadJson());
    request.files.add(await http.MultipartFile.fromPath("files", imagePath!));

    print("📤 Uploading to: $url");
    print("📋 Fields: ${request.fields}");
    print("📷 Image: $imagePath");

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    print("📥 Response status: ${response.statusCode}");
    print("📥 Response body: $responseBody");

    if (response.statusCode != 200) {
      throw Exception("Upload failed: ${response.statusCode} - $responseBody");
    }
  }
}
