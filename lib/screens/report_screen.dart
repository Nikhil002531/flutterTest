import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;

  ReportDetailScreen({required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  Map<String, dynamic>? report;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchReportDetail();
  }

  Future<void> fetchReportDetail() async {
    try {
      final res = await http.get(
        Uri.parse("https://three9-analysis.onrender.com/reports/${widget.reportId}?collection=detailed"),
      );

      if (res.statusCode == 200) {
        setState(() {
          report = json.decode(res.body);
          loading = false;
        });
      } else {
        throw Exception("Failed to load details");
      }
    } catch (e) {
      print("Error fetching details: $e");
      setState(() => loading = false);
    }
  }

  // ----------------------------
  //   BEAUTIFUL GLASS CARD
  // ----------------------------
  Widget glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      margin: EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  // ----------------------------
  //   TEXT ROW (Title + Value)
  // ----------------------------
  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              )),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(color: Colors.white70, fontSize: 15),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------------------------
      // Same ocean deep gradient as Home
      // ---------------------------------
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Report Details",
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black.withOpacity(0.25),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),

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

        child: loading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : report == null
                ? Center(
                    child: Text("Failed to load report",
                        style: TextStyle(color: Colors.white)))
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 110, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ----------------------------
                        // Header Disaster Title Card
                        // ----------------------------
                        glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report!["disaster_type"] ?? "Unknown Disaster",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Report ID: ${widget.reportId}",
                                style: GoogleFonts.lato(
                                    fontSize: 14, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),

                        // ----------------------------
                        // AI ANALYSIS SECTION
                        // ----------------------------
                        glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("AI Analysis",
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              SizedBox(height: 12),

                              infoRow(
                                "Severity",
                                report!["ai_analysis"]?["severity_score"]
                                        ?.toString() ??
                                    "N/A",
                              ),
                              infoRow(
                                "Urgency",
                                report!["ai_analysis"]?["urgency_level"] ??
                                    "N/A",
                              ),
                              infoRow(
                                "Damage",
                                report!["ai_analysis"]?["damage_assessment"] ??
                                    "N/A",
                              ),
                              infoRow(
                                "Confidence",
                                report!["ai_analysis"]?["confidence"]
                                        ?.toString() ??
                                    "N/A",
                              ),
                            ],
                          ),
                        ),

                        // ----------------------------
                        // LOCATION & VERIFICATION
                        // ----------------------------
                        glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Location & Verification",
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 12),

                              infoRow(
                                "Location",
                                report!["location"] is Map
                                    ? report!["location"]["name"]
                                    : (report!["location"] ?? "Unknown"),
                              ),
                              infoRow(
                                "Verification",
                                report!["verification"]?["verification_result"]
                                        ?["verification_status"] ??
                                    "N/A",
                              ),
                            ],
                          ),
                        ),

                        // ----------------------------
                        // SOCIAL MEDIA ANALYSIS
                        // ----------------------------
                        glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Social Media Signals",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              SizedBox(height: 12),

                              infoRow(
                                "Total Posts",
                                report!["social_analysis"]?["social_data"]
                                        ?["total_posts"]
                                        ?.toString() ??
                                    "0",
                              ),
                              infoRow(
                                "Sentiment",
                                report!["social_analysis"]?["ai_analysis"]
                                        ?["sentiment_classification"] ??
                                    "N/A",
                              ),
                            ],
                          ),
                        ),

                        // ----------------------------
                        // IMAGES SECTION
                        // ----------------------------
                        if (report!["images"] != null &&
                            (report!["images"] as List).isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Attached Images",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 12),
                              ...report!["images"].map<Widget>((img) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black45,
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        )
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        img,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
