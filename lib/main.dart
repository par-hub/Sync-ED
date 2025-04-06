import 'package:flutter/material.dart';
import 'package:flutter_application_1/academic.dart';
import 'package:flutter_application_1/chat.dart';
import 'package:flutter_application_1/profilepage.dart';
import 'package:flutter_application_1/studyplanner.dart';
import 'package:flutter_application_1/bottom.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/profile',
      routes: {
        '/studyplanner': (context) => const StudyPlannerPage(),
        '/profile': (context) => const ProfilePage(),
        '/academic': (context) => const Academic(),
        '/chat': (context) => const ChatPage(),
      },
    );
  }
}
