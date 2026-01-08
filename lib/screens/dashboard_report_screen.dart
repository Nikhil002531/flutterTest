
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _reportCard("Daily Report", Icons.today, Colors.blue),
          _reportCard("Weekly Summary", Icons.calendar_view_week, Colors.orange),
          _reportCard("Monthly Analysis", Icons.bar_chart, Colors.green),
          _reportCard("Incident Reports", Icons.report, Colors.red),
        ],
      ),
    );
  }

  Widget _reportCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
