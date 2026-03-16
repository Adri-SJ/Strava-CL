import 'package:flutter/material.dart';
import 'feed_screen.dart';   // Feed/Usuario
import 'routes_screen.dart'; // Rutas
import 'record_screen.dart'; // Grabar Ruta
import 'profile_screen.dart'; // Tu (Estadísticas)

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Lista de las pantallas basadas en tus fotos
  final List<Widget> _screens = [
    const FeedScreen(),    // Pantalla de Usuario (Mockup 3)
    const RoutesScreen(),  // Pantalla de Rutas (Mockup 4)
    const RecordScreen(),  // Pantalla de Grabar (Mockup 5)
    const ProfileScreen(), // Pantalla de Estadísticas (Mockup 6)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: const Color(0xFFFC5200), 
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: ''),
        ],
      ),
    );
  }
}