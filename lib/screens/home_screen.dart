import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../widgets/sidebar_menu.dart';
import '../auth/wrapper_screen.dart';
import './report_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> reports = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      final response = await http.get(
        Uri.parse("https://three9-analysis.onrender.com/reports?limit=50&skip=0&collection=basic"),
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,

      // *************************************
      //      IMPROVED APPBAR & COLORS
      // *************************************
      appBar: AppBar(
        title: Text(
          "🌊 Disaster Reports",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.2),
      ),

      // *************************************
      //         FIX DARK TEXT IN DRAWER
      // *************************************
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color(0xFF002855), // deep sea blue background
        ),
        child: SidebarMenu(),
      ),

      // *************************************
      //             BEAUTIFUL BODY
      // *************************************
      body: Container(
        decoration: BoxDecoration(
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
          padding: const EdgeInsets.only(top: 110, left: 16, right: 16),
          child: loading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : reports.isEmpty
                  ? Center(
                      child: Text(
                        "No reports found",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];

                        // SAFE LOCATION EXTRACT FIX
                        String locationName =
                            report["location"] is Map
                                ? report["location"]["name"]
                                : report["location"] ?? "Unknown";

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

                          // *************************************
                          //   GLASSMORPHIC, PREMIUM-LOOK CARD
                          // *************************************
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.white.withOpacity(0.08),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(20),
                              leading: CircleAvatar(
                                backgroundColor: Colors.white24,
                                child:
                                    Icon(Icons.warning, color: Colors.white),
                              ),
                              title: Text(
                                report["disaster_type"] ?? "Unknown",
                                style: GoogleFonts.poppins(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                "Location: $locationName",
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
