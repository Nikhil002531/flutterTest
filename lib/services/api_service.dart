import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/disaster_report.dart';

class ApiService {
  static const String apiUrl =
      "https://three9-analysis.onrender.com/dashboard/map-data";

  static Future<List<DisasterReport>> fetchReports() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode != 200) {
      throw Exception("Failed to load data: ${response.statusCode}");
    }

    final decoded = jsonDecode(response.body);
    final List list = decoded["map_points"];

    return list.map((e) => DisasterReport.fromJson(e)).toList();
  }
}
