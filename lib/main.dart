import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pixel_trade/pages/login_page.dart';
import 'package:pixel_trade/pages/home_page.dart';
import 'package:pixel_trade/services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Trade',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A192F), // Deep dark blue
        primaryColor: const Color(0xFF64FFDA), // Cyan accent
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF172A45), // Dark blue surface
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF172A45), // Dark blue surface
          selectedItemColor: Color(0xFF64FFDA), // Cyan accent
          unselectedItemColor: Color(0xFF8892B0), // Muted blue-grey
        ),
        cardColor: const Color(0xFF172A45), // Dark blue surface
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF64FFDA), // Cyan accent
            foregroundColor: const Color(0xFF0A192F), // Deep dark blue
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE6F1FF)), // Light blue-white
          bodyMedium: TextStyle(color: Color(0xFFE6F1FF)), // Light blue-white
          titleLarge: TextStyle(color: Color(0xFFE6F1FF)), // Light blue-white
        ),
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If there's no user data, show the login page
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // If we have user data, show the home page
        return const HomePage();
      },
    );
  }
}
