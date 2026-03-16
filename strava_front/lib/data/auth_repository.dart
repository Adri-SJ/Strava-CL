import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthRepository {
  final String _baseUrl = "http://159.54.147.165:8000";

  // Registro de usuario
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

  // Login
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "username": "",
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  // Crear actividad inicial (Presionar Play)
  Future<int?> crearActividad(String tipo) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/actividades/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tipo_deporte": tipo,
          "distancia_total": 0.0
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['id'];
      }
      return null;
    } catch (e) {
      print("Error al crear actividad: $e");
      return null;
    }
  }

  // Guardar punto GPS individual
  Future<void> enviarPuntoGPS(int actividadId, double lat, double lon, int orden) async {
    try {
      await http.post(
        Uri.parse("$_baseUrl/puntos-ruta/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "actividad_id": actividadId,
          "latitud": lat,
          "longitud": lon,
          "orden": orden
        }),
      );
    } catch (e) {
      print("Error enviando punto: $e");
    }
  }

  // FINALIZAR ACTIVIDAD (Presionar Publicar)
  Future<bool> finalizarActividad(int id, String nombre, String mensaje, double distancia) async {
    try {
      final response = await http.put(
        Uri.parse("$_baseUrl/actividades/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "titulo": nombre,
          "descripcion": mensaje,
          "distancia_km": distancia,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error al finalizar: $e");
      return false;
    }
  }

  // Obtener Feed
  Future<List<dynamic>> obtenerFeed() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/feed/"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error al obtener feed: $e");
      return [];
    }
  }
}