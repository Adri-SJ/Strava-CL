import 'package:flutter/material.dart';
import 'feed_screen.dart';   
import 'routes_screen.dart'; 
import 'record_screen.dart'; 
import 'profile_screen.dart'; 

/// Pantalla contenedora que gestiona la navegación principal de la aplicación.
/// Utiliza un BottomNavigationBar para alternar entre los diferentes módulos funcionales.
class MainNavigationScreen extends StatefulWidget {
  final int userId; // Identificador único del usuario obtenido tras el login
  const MainNavigationScreen({super.key, required this.userId});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Índice para controlar la pantalla activa en el Stack de navegación
  int _selectedIndex = 0;

  // Lista de widgets que representan las secciones principales de la app
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Inicialización de pantallas inyectando el userId donde se requiere 
    // persistencia o filtrado de datos específicos del usuario.
    _screens = [
      const FeedScreen(),            // Módulo de comunidad global
      const RoutesScreen(),          // Exploración de rutas en el mapa
      RecordScreen(userId: widget.userId), // Módulo de grabación de actividad
      ProfileScreen(userId: widget.userId), // Panel de estadísticas personales
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Renderizado dinámico de la pantalla según el índice seleccionado
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        // Actualización del estado para refrescar la interfaz al cambiar de pestaña
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed, // Mantiene los iconos fijos sin animaciones de desplazamiento
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: const Color(0xFFFC5200), // Color naranja corporativo (Strava style)
        unselectedItemColor: Colors.white60,
        showSelectedLabels: false, // Estética limpia sin etiquetas de texto
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