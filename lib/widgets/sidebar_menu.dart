
import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/upload_screen.dart';
import '../screens/funds_screen.dart';
import '../screens/home_screen.dart';

class SidebarMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Center(
              child: Text(
                "Disaster News",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen())),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text("Dashboard"),
            onTap: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => DashboardScreen())),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text("Upload"),
            onTap: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => UploadScreen())),
          ),
          ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text("Raised Funds"),
            onTap: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => FundsScreen())),
          ),
          Spacer(),
          Divider(),
          ListTile(
            leading: Icon(Icons.login),
            title: Text("Sign In / Sign Up"),
            onTap: () {}, // We'll implement later
          ),
        ],
      ),
    );
  }
}
