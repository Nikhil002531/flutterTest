class DisasterReport {
  final String imagePath;
  final double latitude;
  final double longitude;
  final String location;
  final String timestamp;

  DisasterReport({
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      "image_path": imagePath,
      "latitude": latitude,
      "longitude": longitude,
      "location": location,
      "timestamp": timestamp,
    };
  }
}
