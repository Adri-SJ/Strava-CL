import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

/// Pantalla principal de la comunidad (Feed).
/// Consume los datos globales del servidor para mostrar las rutas de todos los usuarios.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final AuthRepository _authRepo = AuthRepository();
  
  // Credenciales y configuración de red para acceso a mapas y almacenamiento en OCI
  final String _googleApiKey = ""; 
  final String _serverIp = "http://159.54.147.165:8000";

  /// Genera dinámicamente una URL para la Google Maps Static API.
  /// Transforma la lista de coordenadas GPS en una polilínea visual sobre un mapa base oscuro.
  String _generateStaticMapUrl(List<dynamic> puntos) {
    if (puntos.isEmpty) return "";
    
    // Configuración de estilo de la línea: Color naranja corporativo y grosor de 6px
    String path = "color:0xfc5200ff|weight:6";
    for (var p in puntos) {
      path += "|${p['latitud']},${p['longitud']}";
    }
    
    // El tamaño se ajusta a 600x300 para optimizar el aspecto en dispositivos móviles
    return "https://maps.googleapis.com/maps/api/staticmap?size=600x300&maptype=dark&path=$path&key=$_googleApiKey";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo oscuro para contraste deportivo
      appBar: AppBar(
        title: const Text("ACTIVIDADES", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      // Carga asíncrona de datos desde el repositorio
      body: FutureBuilder<List<dynamic>>(
        future: _authRepo.obtenerFeed(),
        builder: (context, snapshot) {
          // Indicador de carga mientras se recibe la respuesta de la API
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orange));
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final act = snapshot.data![index];
              final puntos = act['puntos'] ?? [];
              final String mapUrl = _generateStaticMapUrl(puntos);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabecera: Identificación del usuario y fecha del registro
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFC5200), 
                        child: Icon(Icons.person, color: Colors.white)
                      ),
                      title: Text(act['titulo'] ?? "Caminata", 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(act['fecha']?.substring(0, 10) ?? "2026-03-18", 
                        style: const TextStyle(color: Colors.grey)),
                    ),

                    // Resumen de métricas: Distancia recorrida y modalidad
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          _stat("DISTANCIA", "${act['distancia_km']?.toStringAsFixed(2) ?? "0.00"} km"),
                          const SizedBox(width: 25),
                          _stat("TIPO", "Carrera"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Sección de Mapa: Renderiza la imagen generada por Google Maps Static API.
                    // Se utiliza este método en lugar de mapas interactivos para optimizar el rendimiento del ListView.
                    Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.black26,
                      child: mapUrl.isNotEmpty 
                        ? Image.network(
                            mapUrl, 
                            fit: BoxFit.cover, 
                            errorBuilder: (_, __, ___) => _mapError() // Manejo de fallback si falla la API
                          )
                        : _mapError(),
                    ),

                    // Sección de Fotografía: Muestra la evidencia capturada por el usuario.
                    // Si no existe, se mantiene un placeholder para conservar la estructura visual.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      child: act['ruta_foto'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network("$_serverIp/${act['ruta_foto']}", fit: BoxFit.fitWidth),
                          )
                        : Container(
                            height: 100,
                            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
                            child: const Center(
                              child: Text("Sin foto de la ruta", style: TextStyle(color: Colors.white24))
                            ),
                          ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Widget de respaldo en caso de que el mapa no pueda ser renderizado
  Widget _mapError() => const Center(child: Icon(Icons.map_outlined, color: Colors.white12, size: 50));

  /// Helper para estandarizar el diseño de las etiquetas de estadísticas
  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}