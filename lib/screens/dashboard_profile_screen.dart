import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile_screen.dart';

class DashboardProfileScreen extends StatefulWidget {
  const DashboardProfileScreen({super.key});

  @override
  State<DashboardProfileScreen> createState() =>
      _DashboardProfileScreenState();
}

class _DashboardProfileScreenState extends State<DashboardProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  String fullName = "";
  String email = "";
  String bio = "";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      setState(() {
        fullName = doc['fullName'] ?? 'No Name';
        bio = doc['bio'] ?? '';
        email = user!.email ?? '';
        loading = false;
      });
    } else {
      setState(() {
        email = user!.email ?? '';
        loading = false;
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.blue,
                    child: Text(
                      fullName.isNotEmpty
                          ? fullName[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],

                  const SizedBox(height: 30),

                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text("Edit Profile"),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(),
                        ),
                      );
                      _loadUserProfile(); // 🔄 refresh after edit
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text("Change Password"),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Password change coming soon"),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
    );
  }
}
