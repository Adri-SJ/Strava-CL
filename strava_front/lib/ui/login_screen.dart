import 'package:flutter/material.dart';
import 'main_navigation.dart'; // Importa la navegación que orquestará tus fotos

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  // Método con Bypass temporal para navegar sin conexión a BD
  void _handleLogin() {
    // Navegación directa para probar la fluidez (60fps) requerida [cite: 14]
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const MainNavigationScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo oscuro para alta fidelidad con tu mockup [cite: 8, 36]
      backgroundColor: const Color(0xFF1F1F1F), 
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
          child: Column(
            children: [
              // 1. Avatar Rosa (Fidelidad visual del mockup) [cite: 7]
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFFF8A80),
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 50),
              
              // 2. Campo de Email (Estilo redondeado de tu imagen)
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[300],
                  hintText: "Email",
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), 
                    borderSide: BorderSide.none
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // 3. Campo de Password
              TextField(
                controller: _passController,
                obscureText: true,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[300],
                  hintText: "Contraseña",
                  hintStyle: const TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), 
                    borderSide: BorderSide.none
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // 4. Botón de Entrar (Naranja corporativo) [cite: 36]
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC5200),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                ),
                child: const Text(
                  "ENTRAR", 
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}