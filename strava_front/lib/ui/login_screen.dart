import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false; // Para mostrar un loader mientras el servidor responde

  // NUEVO MÉTODO: Conexión real a Oracle Cloud
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      _showError("Por favor, llena todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // URL de tu instancia de OCI
      final url = Uri.parse("http://159.54.147.165:8000/auth/login");
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": "temp", // Tu esquema pide username, aunque el login use email
          "email": _emailController.text.trim(),
          "password": _passController.text,
        }),
      );

      if (response.statusCode == 200) {
        // LOGIN EXITOSO
        if (!mounted) return;
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const MainNavigationScreen())
        );
      } else {
        // ERROR DE CREDENCIALES (403 u otros)
        _showError("Correo o contraseña incorrectos");
      }
    } catch (e) {
      // ERROR DE RED (Si el servidor está apagado o no hay internet)
      _showError("Error de conexión con el servidor");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F), 
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color.fromARGB(255, 252, 125, 109),
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 50),
              
              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputStyle("Email"),
              ),
              const SizedBox(height: 20),
              
              // Password
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: _inputStyle("Contraseña"),
              ),
              const SizedBox(height: 40),
              
              // Botón con Loader
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC5200),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("ENTRAR", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color.fromARGB(196, 224, 224, 224),
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
    );
  }
}