import 'package:flutter/material.dart';
import 'intro_screen.dart'; // first intro page

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Tap anywhere to go to IntroScreen1
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => IntroScreen()),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with opacity
            Image.asset(
              "assets/images/welcome_bg.jpg",
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.75),
              colorBlendMode: BlendMode.darken,
            ),

            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 60),

                // Title section
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "OCEAN",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.anchor, color: Colors.white, size: 35),
                      ],
                    ),
                    Text(
                      "  WATCH",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "“Every Post Counts for Coastal Safety”",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Get real-time alerts,\ninteractive maps, and AI-powered social media insights\nto spot hidden hazards",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Welcome text
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      children: [
                        TextSpan(
                          text: "WEL",
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: "COME",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


