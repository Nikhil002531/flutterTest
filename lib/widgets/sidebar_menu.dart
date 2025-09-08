import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/dashboard_screen.dart';
import '../screens/upload_screen.dart';
import '../screens/funds_screen.dart';
import '../screens/home_screen.dart';
import '../auth/signin_screen.dart';
import '../screens/profile_screen.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          // 🔹 User Header
          if (user != null)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return UserAccountsDrawerHeader(
                    accountName: Text("Loading..."),
                    accountEmail: Text(user.email ?? ""),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.teal, size: 40),
                    ),
                    decoration: BoxDecoration(color: Colors.teal),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(user.uid)
                      .set({
                    "fullName": user.displayName ?? "USER",
                    "bio": "",
                    "phone": "",
                    "email": user.email,
                    "photoUrl": "",
                    "createdAt": FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));

                  return UserAccountsDrawerHeader(
                    accountName: Text(user.displayName ?? "USER",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    accountEmail: Text(user.email ?? "",
                        style: TextStyle(fontSize: 14)),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.teal, size: 40),
                    ),
                    decoration: BoxDecoration(color: Colors.teal),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final displayName = data["fullName"] ?? "USER";
                final bio = data["bio"] ?? "";
                final phone = data["phone"] ?? "";
                final profilePhotoUrl = data["photoUrl"] ?? "";

                return UserAccountsDrawerHeader(
                  accountName: Text(
                    displayName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  accountEmail: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email ?? "",
                        style: TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (bio.isNotEmpty)
                        Text(bio, style: TextStyle(fontSize: 12)),
                      if (phone.isNotEmpty)
                        Text("📞 $phone", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: profilePhotoUrl.isNotEmpty
                        ? NetworkImage(profilePhotoUrl)
                        : null,
                    backgroundColor: profilePhotoUrl.isEmpty
                        ? Colors.white
                        : Colors.transparent,
                    child: profilePhotoUrl.isEmpty
                        ? Icon(Icons.person, size: 40, color: Colors.teal)
                        : null,
                  ),
                  decoration: BoxDecoration(color: Colors.teal),
                );
              },
            )
          else
            UserAccountsDrawerHeader(
              accountName: Text("USER",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              accountEmail: Text(""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.teal, size: 40),
              ),
              decoration: BoxDecoration(color: Colors.teal),
            ),

          // 🔹 Sidebar Options
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text("Dashboard"),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text("Upload"),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => UploadScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text("Raised Funds"),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => FundsScreen()),
            ),
          ),

          Spacer(),
          Divider(),

          // 🔹 Auth Options
          if (user == null)
            ListTile(
              leading: Icon(Icons.login),
              title: Text("Sign In / Sign Up"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AuthScreen()),
              ),
            )
          else
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AuthScreen()),
                );
              },
            ),
        ],
      ),
    );
  }
}
