
import 'package:flutter/material.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/news_card.dart';
import '../models/news.dart';

class HomeScreen extends StatelessWidget {
  final List<News> mockNews = [
    News(title: "Flood in Kerala", description: "Heavy rain causes flooding in Kochi."),
    News(title: "Forest Fire", description: "Wildfire spreading near Bandipur forest."),
    News(title: "Earthquake Tremors", description: "Mild tremors felt in Assam region."),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Disaster News")),
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
