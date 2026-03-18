import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/auth_repository.dart';
import 'activity_detail_screen.dart';

/// Pantalla de exploración de rutas.
/// Visualiza en un mapa interactivo todas las actividades registradas en la base de datos central.
class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  final AuthRepository _repo = AuthRepository();
  
  // Conjunto de marcadores para representar las ubicaciones de inicio de las rutas
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Carga inicial de datos geográficos al montar el widget
    _cargarRutasCercanas();
  }

  /// Recupera todas las rutas del backend y genera marcadores para el mapa.
  Future<void> _cargarRutasCercanas() async {
    final rutas = await _repo.obtenerTodasLasRutas();
    
    Set<Marker> nuevosMarkers = {};

    for (var ruta in rutas) {
      // Verificación de integridad: solo se mapean rutas que contengan puntos GPS
      if (ruta['puntos'] != null && ruta['puntos'].isNotEmpty) {
        // Se utiliza el primer punto registrado como coordenada de anclaje del marcador
        final primerPunto = ruta['puntos'][0];
        
        nuevosMarkers.add(
          Marker(
            markerId: MarkerId(ruta['id'].toString()),
            position: LatLng(primerPunto['latitud'], primerPunto['longitud']),
            // Ventana de información interactiva al tocar el marcador
            infoWindow: InfoWindow(
              title: ruta['titulo'],
              snippet: "${ruta['distancia_km'].toStringAsFixed(2)} km - Toca para ver detalle",
              onTap: () {
                // Navegación hacia la pantalla de detalle enviando el objeto completo de la ruta
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivityDetailScreen(actividad: ruta)),
                );
              },
            ),
            // Personalización estética del marcador con el color de identidad de la app
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          ),
        );
      }
    }

    // Actualización del estado de la UI con los nuevos marcadores generados
    setState(() {
      _markers = nuevosMarkers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Capa base: Mapa de Google configurado con el centro en Oaxaca de Juárez
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(17.0654, -96.7236), 
              zoom: 13,
            ),
            markers: _markers,
            myLocationEnabled: true, // Habilita el punto azul de la ubicación actual
            mapType: MapType.normal,
            style: _mapStyle, // Estilo visual personalizado (Custom Map Style)
          ),
          
          // Indicador de progreso mientras se obtienen los datos del servidor en OCI
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFFFC5200))),
          
          // Capa superior: Buscador visual (Placeholder estético para la UI de búsqueda)
          Positioned(
            top: 50, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Buscar rutas en Oaxaca...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Color(0xFFFC5200)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Definición JSON del estilo del mapa: Inversión de colores y etiquetas claras
  final String _mapStyle = '''[ { "featureType": "all", "elementType": "labels.text.fill", "stylers": [ { "color": "#ffffff" } ] }, { "featureType": "all", "elementType": "labels.text.stroke", "stylers": [ { "color": "#000000" }, { "lightness": 13 } ] } ]''';
}