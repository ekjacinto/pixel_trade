import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tcgp_trade/pages/login_page.dart';
import 'package:tcgp_trade/pages/home_page.dart';
import 'package:tcgp_trade/services/auth_service.dart';
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
      title: 'TCGP Trader',
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
        // Debug print for auth state changes
        print('Auth state changed: ${snapshot.connectionState}, hasData: ${snapshot.hasData}');
        if (snapshot.hasError) {
          print('Auth state error: ${snapshot.error}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: snapshot.hasData
              ? const HomePage(key: ValueKey('home'))
              : const LoginPage(key: ValueKey('login')),
        );
      },
    );
  }
}
