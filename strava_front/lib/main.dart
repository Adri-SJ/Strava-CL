import 'package:flutter/material.dart';
import 'ui/welcome_screen.dart';

void main() {
  
  
  runApp(const MainApp());


}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const WelcomeScreen(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFC5200),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1F1F1F)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFC5200),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
