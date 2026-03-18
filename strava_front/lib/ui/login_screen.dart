import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main_navigation.dart';

/// Pantalla encargada de la autenticación de usuarios.
/// Gestiona el envío de credenciales al backend y la redirección inicial de la app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar la entrada de texto del usuario
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  
  // Estado para gestionar el feedback visual durante peticiones asíncronas
  bool _isLoading = false; 

  /// Lógica principal de inicio de sesión.
  /// Se conecta directamente con la instancia de Oracle Cloud Infrastructure (OCI).
  Future<void> _handleLogin() async {
    // Validación básica de campos vacíos antes de realizar la petición
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      _showError("Por favor, llena todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Endpoint de autenticación en el servidor FastAPI
      final url = Uri.parse("http://159.54.147.165:8000/auth/login");
      
      // Petición POST enviando credenciales en formato JSON
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": "temp", // Requerido por el esquema de validación Pydantic en el backend
          "email": _emailController.text.trim(),
          "password": _passController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Al obtener una respuesta exitosa, se procesa el JSON para extraer el ID del usuario
        final Map<String, dynamic> data = jsonDecode(response.body);
        final int userId = data['user_id'];

        // Verificación de seguridad para asegurar que el widget sigue en el árbol antes de navegar
        if (!mounted) return;

        // Redirección a la navegación principal inyectando el ID de usuario para filtrar datos personales
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(userId: userId),
          ),
        );
      } else {
        // Manejo de errores de credenciales (ej. error 403 Forbidden)
        _showError("Correo o contraseña incorrectos");
      }
    } catch (e) {
      // Manejo de excepciones de red o servidor inaccesible
      _showError("Error de conexión con el servidor");
    } finally {
      // Restablece el estado de carga independientemente del resultado de la petición
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Despliega un SnackBar para notificar errores al usuario de forma no intrusiva
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F), // Estética en modo oscuro
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
          child: Column(
            children: [
              // Identificador visual de usuario
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color.fromARGB(255, 252, 125, 109),
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 50),
              
              // Campo de entrada para correo electrónico con teclado optimizado
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputStyle("Email"),
              ),
              const SizedBox(height: 20),
              
              // Campo de contraseña con máscara de seguridad activa
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: _inputStyle("Contraseña"),
              ),
              const SizedBox(height: 40),
              
              // Botón de acción con lógica de bloqueo durante el procesamiento
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC5200), // Naranja corporativo
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("ENTRAR", 
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold
                      )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Define el estilo visual estándar para los campos de entrada de la interfaz
  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color.fromARGB(196, 224, 224, 224),
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20), 
        borderSide: BorderSide.none
      ),
    );
  }
}