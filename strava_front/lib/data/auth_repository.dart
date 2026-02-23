import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthRepository {
  // IP especial para que el emulador Android vea tu servidor local
  final String _baseUrl = "http://10.0.2.2:8000";

  // Método para crear cuenta (Fase 2: Registro)
  Future<bool> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error en registro: $e");
      return false;
    }
  }

  // MÉTODO QUE FALTABA: Iniciar sesión (Fase 2: Login) [cite: 55, 59]
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "username": "", // Tu API en Python espera este campo
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error de conexión al servidor: $e");
      return false;
    }
  }
}