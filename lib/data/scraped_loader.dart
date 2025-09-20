// lib/data/scraped_loader.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/disaster_report.dart';

Future<List<DisasterReport>> loadReportsFromAsset() async {
  final raw = await rootBundle.loadString('assets/data/scraped_posts.json');
  final parsed = jsonDecode(raw) as Map<String, dynamic>;
  if (parsed['posts'] == null) return [];
  final posts = (parsed['posts'] as List).cast<Map<String, dynamic>>();
  final reports = posts.map((p) => DisasterReport.fromScraperMap(p)).toList();
  return reports;
}
