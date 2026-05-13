import 'package:flutter/material.dart';
import 'feed_screen.dart';   
import 'routes_screen.dart'; 
import 'record_screen.dart'; 
import 'profile_screen.dart'; 
import 'AvisosScreen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int userId; 
  const MainNavigationScreen({super.key, required this.userId});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const FeedScreen(),            
      const RoutesScreen(),          
      RecordScreen(userId: widget.userId), 
      ProfileScreen(userId: widget.userId), 
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
    
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Stack(
        alignment: Alignment.topRight,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Navegación directa al Tablero de Avisos
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AvisosScreen(userId: widget.userId)),
              );
            },
            backgroundColor: const Color(0xFF4CAF50), // Verde para resaltar del naranja del menú
            elevation: 8,
            child: const Icon(Icons.campaign, size: 32, color: Colors.white),
          ),
          
          // Badge de notificación (el circulito rojo con el número)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
              child: const Text(
                '1',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: const Color(0xFFFC5200), 
        unselectedItemColor: Colors.white60,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked), label: 'Grabar'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Perfil'),
        ],
      ),
    );
  }
}