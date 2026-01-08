
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: notifications,
            onChanged: (val) => setState(() => notifications = val),
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: darkMode,
            onChanged: (val) => setState(() => darkMode = val),
            secondary: const Icon(Icons.dark_mode),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About App"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
