import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/news_card.dart';
import '../models/news.dart';
import '../auth/wrapper_screen.dart'; // Import your wrapper

class HomeScreen extends StatelessWidget {
  final List<News> mockNews = [
    News(title: "Flood in Kerala", description: "Heavy rain causes flooding in Kochi."),
    News(title: "Forest Fire", description: "Wildfire spreading near Bandipur forest."),
    News(title: "Earthquake Tremors", description: "Mild tremors felt in Assam region."),
  ];

  @override
  Widget build(BuildContext context) {
    // Check current user
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Disaster News"),
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // Navigate via WrapperScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => WrapperScreen()),
                );
              },
            )
        ],
      ),
      drawer: SidebarMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Stay informed about disasters near you.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: mockNews.length,
                itemBuilder: (context, index) {
                  return NewsCard(news: mockNews[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
