import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../widgets/sidebar_menu.dart';
import './report_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> reports = [];
  bool loading = true;

  Map<String, bool> liked = {};
  Map<String, bool> saved = {};

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
          reports = data["reports"];
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

  void showComments(String postId) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF002545),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Comments",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Expanded(
                child: ListView(
                  children: [
                    Text("No comments yet...", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void sharePost(String description) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF002545),
      context: context,
      builder: (_) {
        return Container(
          height: 180,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: const [
              Text("Share Report", style: TextStyle(fontSize: 18, color: Colors.white)),
              SizedBox(height: 20),
              Text("Sharing is not implemented yet.", style: TextStyle(color: Colors.white54)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "🌊 Disaster Feed",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black.withOpacity(0.2),
        elevation: 0,
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(canvasColor: const Color(0xFF002855)),
        child: SidebarMenu(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF001B48),
              Color(0xFF003D73),
              Color(0xFF0077B6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 110, left: 12, right: 12),
          child: loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : reports.isEmpty
              ? const Center(
            child: Text(
              "No reports found",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          )
              : ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];

              String postId = report["id"].toString();

              String locationName = report["location"] is Map
                  ? report["location"]["name"]
                  : "Unknown";

              // ⭐ FIX: Correct backend image field
              String imageUrl = (report["images"] != null &&
                  report["images"].isNotEmpty)
                  ? report["images"][0]
                  : "https://via.placeholder.com/600x400?text=No+Image";

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.warning, color: Colors.white),
                      ),
                      title: Text(
                        report["disaster_type"] ?? "Disaster Report",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        locationName,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing:
                      const Icon(Icons.more_vert, color: Colors.white70),
                    ),

                    // ⭐ FIXED IMAGE SECTION
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 260,
                            color: Colors.black26,
                            child: const Center(
                              child:
                              Icon(Icons.broken_image, color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                liked[postId] = !(liked[postId] ?? false);
                              });
                            },
                            child: Icon(
                              liked[postId] == true
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: liked[postId] == true
                                  ? Colors.red
                                  : Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => showComments(postId),
                            child: const Icon(Icons.mode_comment_outlined,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => sharePost(report["description"] ?? ""),
                            child: const Icon(Icons.send_outlined,
                                color: Colors.white, size: 28),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                saved[postId] = !(saved[postId] ?? false);
                              });
                            },
                            child: Icon(
                              saved[postId] == true
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        report["description"] ?? "No description available",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
