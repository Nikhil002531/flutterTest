// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
// import 'package:latlong2/latlong.dart';
// import '../models/disaster_report.dart';
// import '../data/scraped_loader.dart';
//
// class MapScreen extends StatefulWidget {
//   const MapScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   String? _filterType;
//   bool _useVectorTiles = false;
//   final MapController _mapController = MapController();
//
//   static const String mapboxToken = "YOUR_MAPBOX_ACCESS_TOKEN";
//   static final LatLng indiaCenter = LatLng(20.5937, 78.9629);
//   static const double indiaZoom = 4.5;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('🌊 Ocean Watch — Hazard Heatmap'),
//         backgroundColor: Colors.blueGrey,
//       ),
//       body: FutureBuilder<List<DisasterReport>>(
//         future: loadReportsFromAsset(),
//         builder: (context, snap) {
//           if (snap.connectionState != ConnectionState.done) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final reports = snap.data ?? [];
//           if (reports.isEmpty) {
//             return const Center(child: Text('No reports available'));
//           }
//
//           final geoReports = reports
//               .where((r) =>
//           r.latitude != null &&
//               r.longitude != null &&
//               (_filterType == null ||
//                   r.disasterType.toLowerCase() ==
//                       _filterType!.toLowerCase()))
//               .toList();
//
//           final heatData = geoReports
//               .map((r) =>
//               WeightedLatLng(LatLng(r.latitude!, r.longitude!), r.intensity))
//               .toList();
//
//           return Stack(
//             children: [
//               FlutterMap(
//                 mapController: _mapController,
//                 options: MapOptions(
//                   initialCenter: indiaCenter,
//                   initialZoom: indiaZoom,
//                 ),
//                 children: [
//                   // Raster or Vector TileLayer
//                   _useVectorTiles
//                       ? TileLayer(
//                     urlTemplate:
//                     "https://api.mapbox.com/styles/v1/mapbox/light-v11/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken",
//                     additionalOptions: {
//                       'accessToken': mapboxToken,
//                       'id': 'mapbox.light',
//                     },
//                     subdomains: [],
//                     tileSize: 512,
//                     userAgentPackageName: 'com.example.sih',
//                   )
//                       : TileLayer(
//                     urlTemplate:
//                     'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
//                     subdomains: const ['a', 'b', 'c'],
//                     additionalOptions: {
//                       'r': '@2x', // load retina tiles
//                     },
//                     userAgentPackageName: 'com.example.sih',
//                   ),
//                   if (heatData.isNotEmpty)
//                     HeatMapLayer(
//                       heatMapDataSource:
//                       InMemoryHeatMapDataSource(data: heatData),
//                       heatMapOptions: HeatMapOptions(
//                         radius: 110,
//                         blurFactor: 1.0,
//                         minOpacity: 0.4,
//                         gradient: {
//                           0.0: Colors.green,
//                           0.4: Colors.yellow,
//                           0.7: Colors.orange,
//                           1.0: Colors.red,
//                         },
//                       ),
//                     ),
//                 ],
//               ),
//
//               // Filter chips
//               Positioned(
//                 top: 12,
//                 left: 12,
//                 right: 12,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       _filterChip("All", null),
//                       _filterChip("Cyclone", "Cyclone"),
//                       _filterChip("Floods", "Floods"),
//                       _filterChip("Tsunami", "Tsunami"),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // Legend
//               Positioned(
//                 left: 12,
//                 bottom: 12,
//                 child: Card(
//                   color: Colors.white.withOpacity(0.85),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   elevation: 6,
//                   child: Container(
//                     width: 180,
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text("🔥 Heatmap Guide",
//                             style: TextStyle(
//                                 color: Colors.black87,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16)),
//                         const SizedBox(height: 8),
//                         Container(
//                           height: 14,
//                           decoration: const BoxDecoration(
//                             borderRadius:
//                             BorderRadius.all(Radius.circular(4)),
//                             gradient: LinearGradient(
//                               colors: [
//                                 Colors.green,
//                                 Colors.yellow,
//                                 Colors.orange,
//                                 Colors.red,
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         const Text(
//                           "Green → Low reports\nYellow → Medium\nRed → High hazard density",
//                           style: TextStyle(color: Colors.black54, fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//
//       // Floating buttons
//       floatingActionButton: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           FloatingActionButton.extended(
//             heroTag: "toggle",
//             backgroundColor: Colors.amber,
//             icon: const Icon(Icons.layers),
//             label: Text(_useVectorTiles ? "Vector" : "Raster"),
//             onPressed: () {
//               setState(() {
//                 _useVectorTiles = !_useVectorTiles;
//               });
//             },
//           ),
//           const SizedBox(height: 12),
//           FloatingActionButton.extended(
//             heroTag: "reset",
//             backgroundColor: Colors.blue,
//             icon: const Icon(Icons.refresh),
//             label: const Text("Reset View"),
//             onPressed: () {
//               _mapController.move(indiaCenter, indiaZoom);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _filterChip(String label, String? type) {
//     final bool selected = _filterType == type;
//     return Padding(
//       padding: const EdgeInsets.only(right: 8),
//       child: ChoiceChip(
//         label: Text(label,
//             style: TextStyle(
//                 color: selected ? Colors.black : Colors.black87,
//                 fontWeight: FontWeight.w600)),
//         selected: selected,
//         selectedColor: Colors.amber,
//         backgroundColor: Colors.grey[300],
//         onSelected: (_) {
//           setState(() {
//             _filterType = type;
//           });
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import '../models/disaster_report.dart';
import '../data/scraped_loader.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ocean Watch — Hazard Heatmap')),
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

          // Markers for tapping
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
                  color: Colors.blueAccent,
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(20.5937, 78.9629), // India
                  initialZoom: 4.5,
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
                        radius: 80,
                        blurFactor: 0.8,
                        minOpacity: 0.4,
                        gradient: {
                          0.0: Colors.green,
                          0.5: Colors.orange,
                          1.0: Colors.red,
                        },
                      ),
                    ),

                  MarkerLayer(markers: markers),
                ],
              ),

              // Legend overlay
              Positioned(
                right: 12,
                bottom: 12,
                child: Card(
                  color: Colors.white.withOpacity(0.9),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _LegendItem(color: Colors.green, label: "Low reports"),
                        _LegendItem(color: Colors.orange, label: "Medium"),
                        _LegendItem(color: Colors.red, label: "High density"),
                      ],
                    ),
                  ),
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
              // Draggable indicator
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
        Icon(icon, size: 20, color: Colors.blueAccent),
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

