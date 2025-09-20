import 'dart:ui'; // 👈 add this for ImageFilter.blur

import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import '../models/disaster_report.dart';
import '../data/scraped_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  final LatLng _initialCenter = LatLng(20.5937, 78.9629); // India
  final double _initialZoom = 4.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🌊 Ocean Watch — Hazard Heatmap')),
      body: FutureBuilder<List<DisasterReport>>(
        future: loadReportsFromAsset(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snap.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('No reports available'));
          }

          // Only keep reports with lat/lon
          final geoReports = reports
              .where((r) => r.latitude != null && r.longitude != null)
              .toList();

          // Heatmap data
          final heatData = geoReports
              .map((r) => WeightedLatLng(
            LatLng(r.latitude!, r.longitude!),
            r.intensity,
          ))
              .toList();

          // Markers
          final markers = geoReports.map((r) {
            return Marker(
              point: LatLng(r.latitude!, r.longitude!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showDetails(context, r),
                child: const Icon(
                  Icons.location_on,
                  size: 36,
                  color: Colors.deepPurpleAccent,
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: _initialZoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.sih',
                  ),

                  if (heatData.isNotEmpty)
                    HeatMapLayer(
                      heatMapDataSource:
                      InMemoryHeatMapDataSource(data: heatData),
                      heatMapOptions: HeatMapOptions(
                        radius: 90,
                        blurFactor: 0.7,
                        minOpacity: 0.3,
                        gradient: {
                          0.0: Colors.blue,
                          0.4: Colors.green,
                          0.7: Colors.orange,
                          1.0: Colors.red,
                        },
                      ),
                    ),

                  MarkerLayer(markers: markers),
                ],
              ),

              // Glass legend
              Positioned(
                right: 12,
                bottom: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter:
                    ImageFilter.blur(sigmaX: 12, sigmaY: 12), // glass effect
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.white.withOpacity(0.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Heatmap Legend",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          _LegendItem(color: Colors.blue, label: "Very Low"),
                          _LegendItem(color: Colors.green, label: "Low"),
                          _LegendItem(color: Colors.orange, label: "Medium"),
                          _LegendItem(color: Colors.red, label: "High Density"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Reset zoom button
              Positioned(
                right: 12,
                bottom: 12,
                child: FloatingActionButton(
                  heroTag: "reset_zoom",
                  backgroundColor: Colors.deepPurple,
                  onPressed: () {
                    _mapController.move(_initialCenter, _initialZoom);
                  },
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDetails(BuildContext context, DisasterReport r) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                r.disasterType,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                r.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey[400]),
              const SizedBox(height: 8),
              _detailRow(Icons.location_on, "Location", r.location),
              const SizedBox(height: 8),
              _detailRow(Icons.access_time, "Time", r.timestamp.toString()),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$title: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 16,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
