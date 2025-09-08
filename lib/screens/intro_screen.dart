import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pagesData = [
    {
      "image": "assets/images/map.png",
      "icon": Icons.warning,
      "iconColor": Colors.orange,
      "topText": "Real-Time Alerts",
      "pinTop": true,
      "desc":
      "Stay updated on unusual tides, flooding, coastal damage, and other hazards through community reports and live social media signals",
    },
    {
      "dualStackImages": [
        "assets/images/disaster.jpg",
        "assets/images/disaster1.jpeg",
      ],
      "desc":
      "See it, snap it, share it. Report flooding or hazards with geo tagged updates because every location matters in a disaster",
    },
    {
      "quadImages": [
        "assets/images/officials.jpeg",
        "assets/images/volunteer.jpeg",
        "assets/images/dataengineer.jpeg",
        "assets/images/citizen.jpeg",
      ],
      "desc":
      "From citizens on the ground to officials in command, Ocean Watch adapts to your role. Together, we create a smarter, safer coastal community",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ Consistent text styles for all screens
    const TextStyle headingStyle = TextStyle(
      fontSize: 27.5,
      fontWeight: FontWeight.w900,
      color: Colors.white,
    );

    const TextStyle descStyle = TextStyle(
      fontSize: 16,
      color: Colors.white70,
      fontWeight: FontWeight.w500,
    );

    return WillPopScope(
      onWillPop: () async {
        if (_currentPage > 0) {
          _pageController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return false;
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => WelcomeScreen()),
          );
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pagesData.length,
              itemBuilder: (context, index) {
                final page = _pagesData[index];

                // ✅ Page with dual stacked images
                if (page.containsKey("dualStackImages")) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildImage(page["dualStackImages"][0]),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Text(
                          page["desc"],
                          style: descStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      _buildImage(page["dualStackImages"][1]),
                    ],
                  );
                }

                // ✅ Page with 4 images grid
                if (page.containsKey("quadImages")) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 2x2 Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: page["quadImages"].length,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemBuilder: (context, i) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                page["quadImages"][i],
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          page["desc"],
                          style: descStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }

                // ✅ Default design (for IntroScreen1 with pinTop)
                return Stack(
                  children: [
                    // Background image
                    Container(
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(page["image"]),
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.25),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                    ),

                    // Description (bottom-center)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 80, left: 30, right: 30),
                        child: Text(
                          page["desc"],
                          style: descStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Top pinned icon + heading
                    if (page.containsKey("pinTop") && page["pinTop"] == true)
                      Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Icon(page["icon"],
                                color: page["iconColor"], size: 80),
                            SizedBox(height: 10),
                            Text(
                              page["topText"] ?? "",
                              style: headingStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),

            // ✅ Bottom nav arrows + dots
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: _currentPage > 0
                        ? () => _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                        : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => WelcomeScreen()),
                      );
                    },
                  ),
                  Row(
                    children: List.generate(_pagesData.length, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.tealAccent
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: _currentPage < _pagesData.length - 1
                        ? () => _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                        : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => HomeScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.28,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset(path, fit: BoxFit.cover),
      ),
    );
  }
}
