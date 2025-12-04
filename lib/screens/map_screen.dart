import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

import '../models/disaster_report.dart';
import '../services/api_service.dart';
import '../widgets/legend_item.dart';
import '../widgets/detail_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _initialCenter = const LatLng(20.5937, 78.9629);
  final double _initialZoom = 4.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🌊 Ocean Watch — Hazard Heatmap")),
      body: FutureBuilder<List<DisasterReport>>(
        future: ApiService.fetchReports(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snap.data!;
          if (reports.isEmpty) {
            return const Center(child: Text("No data found"));
          }

          final heatData = reports
              .map(
                (r) => WeightedLatLng(
              LatLng(r.lat ?? 0, r.lng ?? 0),
              r.severity ?? 0,
            ),
          )
              .toList();

          final markers = reports.map((r) {
            return Marker(
              point: LatLng(r.lat ?? 0, r.lng ?? 0),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => showDetailBottomSheet(context, r),
                child: const Icon(Icons.location_on,
                    size: 36, color: Colors.deepPurple),
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
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.sih',
                  ),
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
              Positioned(
                right: 12,
                bottom: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.white.withOpacity(0.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text("Heatmap Legend",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          LegendItem(color: Colors.blue, label: "Very Low"),
                          LegendItem(color: Colors.green, label: "Low"),
                          LegendItem(color: Colors.orange, label: "Medium"),
                          LegendItem(color: Colors.red, label: "High"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: FloatingActionButton(
                  backgroundColor: Colors.deepPurple,
                  onPressed: () =>
                      _mapController.move(_initialCenter, _initialZoom),
                  child: const Icon(Icons.refresh),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
