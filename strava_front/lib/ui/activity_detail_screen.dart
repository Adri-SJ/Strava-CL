import 'package:flutter/material.dart';

/// Pantalla encargada de mostrar el desglose completo de una actividad específica.
/// Recibe un objeto dinámico (JSON) que contiene estadísticas, coordenadas y multimedia.
class ActivityDetailScreen extends StatelessWidget {
  final dynamic actividad; 

  const ActivityDetailScreen({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    // Generación de la ruta visual mediante Google Maps Static API basada en los puntos GPS guardados
    final String mapUrl = _generateStaticMapUrl(actividad['puntos'] ?? []);
    // Dirección del servidor en Oracle Cloud para recuperar archivos multimedia
    final String serverIp = "http://159.54.147.165:8000";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(actividad['titulo'] ?? "Detalle"),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Visualización del mapa estático con la polilínea de la ruta
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.black,
              child: mapUrl.isNotEmpty 
                ? Image.network(mapUrl, fit: BoxFit.cover)
                : const Icon(Icons.map, color: Colors.white24, size: 80),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la actividad y fecha de realización
                  Text(actividad['titulo'] ?? "Sin título", 
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(actividad['fecha']?.substring(0,10) ?? "", 
                    style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  
                  const Divider(color: Colors.white10, height: 40),
                  
                  // Fila de métricas clave: Distancia total y tipo de deporte
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBigStat("Distancia", "${actividad['distancia_km']?.toStringAsFixed(2)} km"),
                      _buildBigStat("Tipo", actividad['tipo_deporte'] ?? "Carrera"),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  // Bloque de descripción o mensaje del usuario
                  const Text("Descripción", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(actividad['descripcion'] ?? "Sin descripción", 
                    style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  
                  const SizedBox(height: 30),
                  
                  // Renderizado condicional de la fotografía de la ruta si existe en el servidor
                  if (actividad['ruta_foto'] != null) ...[
                    const Text("Foto de la ruta", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network("$serverIp/${actividad['ruta_foto']}"),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una URL para la Google Maps Static API.
  /// Itera sobre la lista de puntos GPS para trazar una polilínea sobre un mapa en modo oscuro.
  String _generateStaticMapUrl(List<dynamic> puntos) {
    if (puntos.isEmpty) return "";
    
    // Configuración estética de la polilínea (Naranja Strava)
    String path = "color:0xfc5200ff|weight:6";
    
    // Concatenación de coordenadas para formar el trayecto
    for (var p in puntos) {
      path += "|${p['latitud']},${p['longitud']}";
    }
    
    return "https://maps.googleapis.com/maps/api/staticmap?size=600x400&maptype=dark&path=$path&key=";
  }

  /// Helper para construir widgets de estadísticas con formato uniforme
  Widget _buildBigStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}