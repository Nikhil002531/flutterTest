import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar_menu.dart';
import '../auth/wrapper_screen.dart';
import '../models/news.dart';
import '../widgets/news_card.dart';

class HomeScreen extends StatelessWidget {
  final List<News> mockNews = [
    News(title: "Cyclone Alert in Bay of Bengal", description: "IMD warns of a severe cyclone approaching the east coast."),
    News(title: "Tsunami Drill in Chennai", description: "Coastal regions participate in a large-scale tsunami preparedness drill."),
    News(title: "Rising Sea Levels", description: "Study shows alarming rise in global sea levels due to melting glaciers."),
    News(title: "Oil Spill in Arabian Sea", description: "Cleanup operations begin after a tanker leak near Mumbai coast."),
    News(title: "Flood in Kerala", description: "Heavy rainfall causes flooding in Kochi; rescue teams deployed."),
    News(title: "Fishing Ban", description: "Seasonal fishing ban announced to conserve marine life."),
    News(title: "Plastic Pollution", description: "Oceans threatened as plastic waste reaches record levels."),
    News(title: "Forest Fire near Coastal Belt", description: "Wildfires reported near coastal forests of Karnataka."),
    News(title: "Shipwreck in Andaman", description: "Cargo ship sinks; Indian Coast Guard begins rescue operation."),
    News(title: "Coral Reefs at Risk", description: "Climate change puts coral ecosystems under extreme stress."),
    News(title: "Drought Impact", description: "Water scarcity affects coastal villages in Tamil Nadu."),
    News(title: "Storm Surge", description: "High tides predicted due to strong winds near Odisha coast."),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "🌊 Ocean Disaster News",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => WrapperScreen()),
                );
              },
            )
        ],
      ),
      drawer: SidebarMenu(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001B48), Color(0xFF005792), Color(0xFF00BBF9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 90, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Stay informed 🌐",
                style: GoogleFonts.lora(
                  textStyle: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                "Latest disasters from oceans, seas & coasts",
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: mockNews.length,
                  itemBuilder: (context, index) {
                    final news = mockNews[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade800, Colors.blue.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          news.title,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          news.description,
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.water_damage, color: Colors.white),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
