
import 'package:flutter/material.dart';
import '../widgets/sidebar_menu.dart';

class FundsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Raised Funds")),
      drawer: SidebarMenu(),
      body: Center(
        child: Text("Funds section coming soon..."),
      ),
    );
  }
}
