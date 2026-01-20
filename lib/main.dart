import 'package:flutter/material.dart'; //main Flutter UI components.
import 'package:supabase_flutter/supabase_flutter.dart'; //Supabase SDK for backend integration.

import 'auth/login_page.dart';
import 'supabase_client.dart'; //Configuration for Supabase connection.

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Ensures Flutter is ready before any async operations (required for plugins like Supabase).

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp()); //Launches the app by running the MyApp widget.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //A MaterialApp that defines the app's global theme and navigation.
      debugShowCheckedModeBanner: false,

      //  GLOBAL DARK THEME
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        scaffoldBackgroundColor: Colors.transparent,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.tealAccent,
          foregroundColor: Colors.black,
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0F2027),
          selectedItemColor: Colors.tealAccent,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      // ENTRY PAGE
      home:
          const LoginPage(), //Users start here to authenticate before accessing the dashboard.
    );
  }
}
