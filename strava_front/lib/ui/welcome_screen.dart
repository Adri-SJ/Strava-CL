import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Imagen de fondo que ocupa toda la pantalla
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 2. Capa oscura para que el texto y botones resalten (Overlay)
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // 3. Contenido (Botones y Logo)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón EMPEZAR (Naranja Strava)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFC5200),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      "EMPEZAR",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Link de Registrarme
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    child: const Text(
                      "Registrarme",
                      style: TextStyle(color: Colors.white70, fontSize: 16, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}