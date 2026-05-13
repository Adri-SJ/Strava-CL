import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Clase encargada de la comunicación con el backend (FastAPI) en Oracle Cloud.
/// Centraliza todas las peticiones HTTP para autenticación y gestión de rutas.
class AuthRepository {
  // IP pública de la instancia de Oracle Cloud Infrastructure (OCI)
  final String _baseUrl = "http://159.54.147.165:8000";

  // Realiza el registro de nuevos usuarios enviando el modelo serializado a JSON
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

  // Validación de credenciales para el inicio de sesión
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "username": "", // Campo requerido por el esquema del backend
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  // Inicializa una nueva actividad en el servidor y retorna su ID único
  Future<int?> crearActividad(String tipo, int userId) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/actividades/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tipo_deporte": tipo,
          "distancia_total": 0.0,
          "usuario_id": userId
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

  // Envía una coordenada GPS individual para persistencia en tiempo real
  Future<void> enviarPuntoGPS(int actividadId, double lat, double lon, int orden) async {
    try {
      await http.post(
        Uri.parse("$_baseUrl/puntos-ruta/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "actividad_id": actividadId,
          "latitud": lat,
          "longitud": lon,
          "orden": orden // Mantiene la secuencia lógica del trayecto
        }),
      );
    } catch (e) {
      print("Error enviando punto: $e");
    }
  }

  // Actualiza los datos finales de la actividad y adjunta la evidencia fotográfica
  // Utiliza MultipartRequest para permitir la subida de archivos binarios al servidor
  Future<bool> finalizarActividad(int id, String nombre, String mensaje, double distancia, String? imagePath) async {
    try {
      var request = http.MultipartRequest(
        'PUT', 
        Uri.parse("$_baseUrl/actividades/$id")
      );

      // Inserción de metadatos de la actividad como campos de formulario
      request.fields['titulo'] = nombre;
      request.fields['descripcion'] = mensaje;
      request.fields['distancia_km'] = distancia.toString();

      // Procesamiento y adjunto de la imagen desde el almacenamiento local
      if (imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto', imagePath)
        );
      }

      var streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      print("Error al finalizar actividad: $e");
      return false;
    }
  }

  // Recupera el listado global de actividades para el feed principal
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

  // Filtra las actividades registradas específicamente por el usuario logueado
  Future<List<dynamic>> obtenerMisActividades(int userId) async {
    final response = await http.get(Uri.parse("$_baseUrl/usuarios/$userId/actividades"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // Consulta todas las rutas disponibles en la base de datos para la función de exploración
  Future<List<dynamic>> obtenerTodasLasRutas() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/explorar/rutas/"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error al explorar rutas: $e");
      return [];
    }
  }

  // NUEVO MÉTODO: Obtiene las coordenadas para el Mapa de Calor de Seguridad
  Future<List<LatLng>> obtenerPuntosSeguros() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/seguridad/heatmap"));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((p) => LatLng(p['lat'], p['lng'])).toList();
      }
      return [];
    } catch (e) {
      print("Error obteniendo heatmap: $e");
      return [];
    }
  }

  Future<bool> publicarAviso(int userId, String contenido, String categoria) async {
  try {
    final response = await http.post(
      Uri.parse("$_baseUrl/avisos/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "usuario_id": userId,
        "contenido": contenido,
        "categoria": categoria
      }),
    );
    return response.statusCode == 200;
  } catch (e) {
    print("Error al publicar aviso: $e");
    return false;
  }
}

Future<List<dynamic>> obtenerAvisos() async {
  try {
    final response = await http.get(Uri.parse("$_baseUrl/avisos/"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  } catch (e) {
    print("Error al obtener avisos: $e");
    return [];
  }
}
}