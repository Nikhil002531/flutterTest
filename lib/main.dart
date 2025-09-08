// import 'package:flutter/material.dart';
// import 'screens/home_screen.dart';
// import 'screens/dashboard_screen.dart';
// import 'screens/upload_screen.dart';
// import 'screens/funds_screen.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "Disaster News",
//       theme: ThemeData(primarySwatch: Colors.teal),
//       home: HomeScreen(),
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Ocean Watch",
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: "Roboto",
      ),
      home: WelcomeScreen(),
    );
  }
}
