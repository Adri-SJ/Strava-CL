import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ui/welcome_screen.dart';
import 'blocs/record_bloc.dart';
import 'data/auth_repository.dart';
import 'ui/feed_screen.dart';

/// Punto de entrada principal de la aplicación.
/// Configura la jerarquía global de estados (BLoC) y el diseño visual base del sistema.
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Implementación de MultiBlocProvider para gestionar estados globales.
    // Inyectamos RecordBloc y AuthRepository al inicio del árbol de widgets.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RecordBloc(AuthRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Strava Clone - Anáhuac Oaxaca',
        // Definición de la pantalla inicial de la aplicación
        home: const WelcomeScreen(),
        
        // Tabla de rutas para navegación nominada entre módulos
        routes: {
          '/feed': (context) => const FeedScreen(),
        },
        
        // Definición del sistema de diseño (Design System).
        // Se establece un tema oscuro (Dark Mode) con colores corporativos personalizados.
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFFC5200), // Naranja característico de Strava
          scaffoldBackgroundColor: const Color(0xFF121212), // Gris neutro oscuro
          
          // Personalización estética de la AppBar (Barra superior)
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1F1F1F),
            elevation: 0,
            centerTitle: true,
          ),
          
          // Estilo global para botones de acción principal (Call to Action)
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC5200),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 18
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),
            ),
          ),
        ),
        // Desactiva la etiqueta 'Debug' en la esquina superior para una apariencia de producción
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}