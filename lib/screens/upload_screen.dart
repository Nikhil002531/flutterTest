import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import '../widgets/sidebar_menu.dart';
import '../models/disaster_report.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  Position? _position;
  String? _address;
  String? _timestamp;
  DisasterReport? _lastReport;
  final ImagePicker _picker = ImagePicker();

  /// Capture image first, then fetch location
  Future<void> _openCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _position = null;
        _address = null;
        _timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      });

      try {
        // 1. Check if location services are enabled
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Please enable location services")),
          );
          return;
        }

        // 2. Check & request permissions
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("❌ Location permission denied")),
            );
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Location permissions permanently denied. Enable in settings."),
            ),
          );
          return;
        }

        // 3. Get current location
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // 4. Reverse geocode
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        final place = placemarks.first;
        final fullAddress =
            "${place.locality}, ${place.administrativeArea}, ${place.country}";

        setState(() {
          _position = position;
          _address = fullAddress;
        });
      } catch (e) {
        print("❌ Location error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Failed to fetch location")),
        );
      }
    }
  }

  /// Finalize & prepare JSON
  void _finalizeReport() {
    if (_image == null || _timestamp == null) return;

    final report = DisasterReport(
      imagePath: _image!.path,
      latitude: _position?.latitude ?? 0.0,
      longitude: _position?.longitude ?? 0.0,
      location: _address ?? "Unknown",
      timestamp: _timestamp!,
    );

    final jsonData = report.toJson();
    print("✅ Prepared JSON: $jsonData");

    setState(() {
      _lastReport = report;
      _image = null; // reset capture
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Report prepared! Ready for backend.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Disaster Report")),
      drawer: SidebarMenu(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Case 1: nothing captured yet
              if (_image == null && _lastReport == null)
                Column(
                  children: [
                    Icon(Icons.camera_alt, size: 80, color: Colors.blueGrey),
                    SizedBox(height: 10),
                    Text("No report submitted yet!",
                        style: TextStyle(fontSize: 16)),
                  ],
                ),

              /// Case 2: preview after capture
              if (_image != null)
                Card(
                  elevation: 5,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Image.file(_image!, height: 200, fit: BoxFit.cover),
                        SizedBox(height: 10),
                        Text("📍 Location: ${_address ?? "Fetching..."}"),
                        Text(
                            "🌐 Lat: ${_position?.latitude ?? "--"}, Lng: ${_position?.longitude ?? "--"}"),
                        Text("🕒 Time: $_timestamp"),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                              child: Text("Retake"),
                            ),
                            ElevatedButton(
                              onPressed: _finalizeReport,
                              child: Text("Upload"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

              /// Case 3: show last uploaded report
              if (_lastReport != null && _image == null)
                Card(
                  elevation: 5,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.file(File(_lastReport!.imagePath),
                            height: 200, fit: BoxFit.cover),
                        SizedBox(height: 10),
                        Text("📍 Location: ${_lastReport!.location}"),
                        Text(
                            "🌐 Lat: ${_lastReport!.latitude}, Lng: ${_lastReport!.longitude}"),
                        Text("🕒 Time: ${_lastReport!.timestamp}"),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _openCamera,
                icon: Icon(Icons.camera_alt),
                label: Text("Open Camera"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
