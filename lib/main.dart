import 'package:flutter/material.dart';
import 'package:flutter_application_1/academic.dart';
import 'package:flutter_application_1/chat.dart';
import 'package:flutter_application_1/login2.dart';
import 'package:flutter_application_1/profilepage.dart';
import 'package:flutter_application_1/registration.dart';
import 'package:flutter_application_1/studyplanner.dart';
import 'package:flutter_application_1/login.dart'; // Add this import
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://axdsnimuwwrvazvmlzle.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4ZHNuaW11d3dydmF6dm1semxlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM1MjQ5OTMsImV4cCI6MjA1OTEwMDk5M30.CxPamCAm4K5socN8g1c9DAQj9qfDvhOEDd206wa2A20',
    authFlowType: AuthFlowType.pkce,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final session = snapshot.data?.session;
          if (session != null) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: SupabaseService().getData('Users'),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                }

                final users = userSnapshot.data ?? [];
                final userExists = users.any((user) => user['user_id'] == session.user.id);

                if (!userExists) {
                  // User not in Users table, sign out and show login
                  Supabase.instance.client.auth.signOut();
                  return _buildLoginNavigator();
                }

                return _buildMainNavigator();
              },
            );
          }

          return _buildLoginNavigator();
        },
      ),
    );
  }

  Widget _buildMainNavigator() {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const ProfilePage());
          case '/studyplanner':
            return MaterialPageRoute(builder: (_) => const StudyPlannerPage());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfilePage());
          case '/academic':
            return MaterialPageRoute(builder: (_) => const Academic());
          case '/chat':
            return MaterialPageRoute(builder: (_) => const ChatPage());
          default:
            return MaterialPageRoute(builder: (_) => const ProfilePage());
        }
      },
    );
  }

  Widget _buildLoginNavigator() {
    return Navigator(
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/login/registration':
            return MaterialPageRoute(builder: (_) => const RegisterPage());
          case '/login/email':
            return MaterialPageRoute(builder: (_) => const LoginPage2());
          default:
            return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
    );
  }
}
