import 'package:flutter/material.dart';
import 'package:untitled1/secondScreen.dart';

import 'locationTester.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Location Tracker',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
      initialRoute: '/',
      routes: {
        '/': (context) =>  LandmarkFinder(),
        '/screen2': (context) =>   Screen2(),
      },
    );
  }
}


