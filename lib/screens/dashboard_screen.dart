
import 'package:flutter/material.dart';
import '../widgets/sidebar_menu.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      drawer: SidebarMenu(),
      body: Center(child: Text("Dashboard Content Coming Soon...")),
    );
  }
}
