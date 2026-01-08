import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/sidebar_menu.dart';
import './report_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> reports = [];
  bool loading = true;

  /// local like system
  Map<String, bool> liked = {};

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://three9-analysis.onrender.com/reports?limit=50&skip=0&collection=detailed",
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          reports = data["reports"] ?? [];
          loading = false;
        });
      } else {
        throw Exception("Failed to load reports");
      }
    } catch (e) {
      print("Error fetching reports: $e");
      setState(() => loading = false);
    }
  }

  // ---------------- LIKE SYSTEM ----------------
  bool isLiked(dynamic report) {
    return liked[report["id"].toString()] == true;
  }

  void toggleLike(dynamic report) {
    final id = report["id"].toString();
    setState(() {
      liked[id] = !(liked[id] ?? false);
    });
  }

  // ---------------- IMAGE VIEWER ----------------
  void openImageViewer(BuildContext context, List images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: PhotoViewGallery.builder(
            itemCount: images.length,
            pageController: PageController(initialPage: index),
            builder: (_, i) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(images[i]),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------- MAP ----------------
  Future<void> openLocation(double lat, double lng) async {
    final url = Uri.parse("https://maps.google.com/?q=$lat,$lng");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open map")),
      );
    }
  }

  // ---------------- SHARE ----------------
  void shareReport(dynamic report) {
    final text =
        "Disaster Report: ${report["disaster_type"] ?? ""}\n"
        "${report["description"] ?? ""}\n"
        "Location: ${report["location"]?["name"] ?? "Unknown"}";
    Share.share(text);
  }

  // ---------------- INFO SHEET ----------------
  void _showInfoSheet(BuildContext context, dynamic report) {
    final verification = report["verification"];
    final searchResults =
        verification?["verification_result"]?["official_verification"]
        ?["search_results"] ??
            [];

    final findings =
    verification?["verification_result"]?["enhanced_analysis"]
    ?["key_findings"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                "Verified Sources",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              if (searchResults.isNotEmpty)
                ...searchResults.map<Widget>((item) {
                  return ListTile(
                    title: Text(item["title"] ?? ""),
                    subtitle: Text(item["snippet"] ?? ""),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () async {
                      final uri = Uri.parse(item["url"]);
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  );
                }),

              const SizedBox(height: 20),
              Text(
                "AI Key Findings",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              if (findings != null)
                ...findings.map<Widget>(
                      (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text("• $f"),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Disaster Feed",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      drawer: SidebarMenu(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          final location = report["location"];
          final images = report["images"];

          final summary =
              report["verification"]?["verification_result"]
              ?["enhanced_analysis"]?["key_findings"]?[0] ??
                  report["social_analysis"]?["ai_analysis"]?["summary"] ??
                  report["description"] ??
                  "No description available";

          /// IMAGE SAFE HANDLING
          Widget imageWidget;
          if (images is List && images.isNotEmpty) {
            imageWidget = GestureDetector(
              onTap: () => openImageViewer(context, images, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  images[0],
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            imageWidget = Container(
              height: 260,
              color: Colors.grey.shade300,
              child: const Icon(Icons.image_not_supported, size: 60),
            );
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ReportDetailScreen(reportId: report["id"]),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child:
                      const Icon(Icons.person, color: Colors.blue),
                    ),
                    title: Text(
                      report["disaster_type"] ?? "Unknown",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: location != null &&
                        location["lat"] != null &&
                        location["lng"] != null
                        ? GestureDetector(
                      onTap: () => openLocation(
                          location["lat"], location["lng"]),
                      child: Text(
                        location["name"] ?? "Unknown Location",
                        style: GoogleFonts.lato(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                        : const Text("Unknown Location"),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () =>
                          _showInfoSheet(context, report),
                    ),
                  ),

                  imageWidget,

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => toggleLike(report),
                          child: Icon(
                            isLiked(report)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 30,
                            color: isLiked(report)
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => shareReport(report),
                          child: const Icon(Icons.send_outlined,
                              size: 30),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      summary,
                      style:
                      GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
