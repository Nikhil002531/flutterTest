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
  String? _selectedDisaster;
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<String> _disasterTypes = [
    "Tsunami",
    "Cyclone",
    "Oil Spill",
    "Flooding",
    "Marine Pollution",
    "Storm Surge",
    "Coral Bleaching",
    "Harmful Algal Bloom",
  ];

  /// Capture image then fetch location
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
        final serviceEnabled = await Geolocator.isLocationServiceEnabled(); //checkPermission from user
        if (!serviceEnabled) return;

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) return;
        }
        if (permission == LocationPermission.deniedForever) return;

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final placemarks =
            await placemarkFromCoordinates(position.latitude, position.longitude);
        final place = placemarks.first;
        final fullAddress =
            "${place.locality}, ${place.administrativeArea}, ${place.country}";

        setState(() {
          _position = position;
          _address = fullAddress;
        });
      } catch (e) {
        print("❌ Location error: $e");
      }
    }
  }

  /// Finalize & prepare JSON
void _finalizeReport() async {
  if (_image == null || _timestamp == null || _selectedDisaster == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("⚠️ Please fill all details before uploading")),
    );
    return;
  }

  // Step 1: Create DisasterReport object
  final report = DisasterReport(
    userId: "test_user_001", // can be dynamic
    imagePath: _image!.path,
    latitude: _position?.latitude,
    longitude: _position?.longitude,
    location: _address ?? "Unknown",
    timestamp: _timestamp!,
    disasterType: _selectedDisaster!,
    description: _descController.text.trim(),
  );

  setState(() {
    _lastReport = report; // store for showing preview
    _image = null;
    _selectedDisaster = null;
    _descController.clear();
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("🌊 Sending report to backend...")),
  );

  // Step 2: Send to backend
  await report.sendToBackend();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("✅ Report uploaded successfully!")),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text("🌊 Upload Disaster Report"),
        backgroundColor: Colors.blue[700],
      ),
      drawer: SidebarMenu(),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_image == null && _lastReport == null)
                Column(
                  children: [
                    Icon(Icons.camera_alt, size: 100, color: Colors.blue[400]),
                    SizedBox(height: 12),
                    Text("No report submitted yet!",
                        style: TextStyle(fontSize: 18, color: Colors.blue[800])),
                  ],
                ),

              if (_image != null)
                Card(
                  color: Colors.white,
                  elevation: 8,
                  margin: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            _image!,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text("📍 Location: ${_address ?? "Fetching..."}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            "🌐 Lat: ${_position?.latitude ?? "--"}, Lng: ${_position?.longitude ?? "--"}"),
                        Text("🕒 Time: $_timestamp"),
                        SizedBox(height: 15),

                        /// Dropdown for disaster type
                        DropdownButtonFormField<String>(
                          value: _selectedDisaster,
                          decoration: InputDecoration(
                            labelText: "Select Disaster Type",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _disasterTypes
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedDisaster = val;
                            });
                          },
                        ),
                        SizedBox(height: 15),

                        /// Description box
                        TextField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Describe the disaster...",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton.icon(
                              icon: Icon(Icons.refresh),
                              onPressed: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                              label: Text("Retake"),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _finalizeReport,
                              icon: Icon(Icons.cloud_upload),
                              label: Text("Upload"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

              if (_lastReport != null && _image == null)
                Card(
                  color: Colors.white,
                  elevation: 5,
                  margin: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            File(_lastReport!.imagePath),
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("📍 ${_lastReport!.location}"),
                        Text(
                            "🌐 Lat: ${_lastReport!.latitude}, Lng: ${_lastReport!.longitude}"),
                        Text("🕒 ${_lastReport!.timestamp}"),
                        Text("🌊 Type: ${_lastReport!.disasterType}"),
                        Text("📝 Desc: ${_lastReport!.description}"),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
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
