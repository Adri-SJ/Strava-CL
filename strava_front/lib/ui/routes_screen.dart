import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/auth_repository.dart';
import '../blocs/record_bloc.dart';
import '../blocs/record_state.dart';
import 'activity_detail_screen.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  final AuthRepository _repo = AuthRepository();
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarRutasCercanas();
    // Disparamos la carga de zonas seguras al iniciar
    context.read<RecordBloc>().add(LoadSecurityHeatmapEvent());
  }

  Future<void> _cargarRutasCercanas() async {
    final rutas = await _repo.obtenerTodasLasRutas();
    Set<Marker> nuevosMarkers = {};
    for (var ruta in rutas) {
      if (ruta['puntos'] != null && ruta['puntos'].isNotEmpty) {
        final primerPunto = ruta['puntos'][0];
        nuevosMarkers.add(
          Marker(
            markerId: MarkerId(ruta['id'].toString()),
            position: LatLng(primerPunto['latitud'], primerPunto['longitud']),
            infoWindow: InfoWindow(
              title: ruta['titulo'],
              snippet: "${ruta['distancia_km'].toStringAsFixed(2)} km - Ver detalle",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityDetailScreen(actividad: ruta)));
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          ),
        );
      }
    }
    setState(() {
      _markers = nuevosMarkers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordBloc, RecordState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(17.0041, -96.7112), // CENTRADO EN ANÁHUAC OAXACA
                  zoom: 15,
                ),
                markers: _markers,
                // PINTAMOS EL MAPA DE CALOR (Tropicalización)
                circles: state.puntosSeguros.map((punto) => Circle(
                  circleId: CircleId("seguro_${punto.latitude}"),
                  center: punto,
                  radius: 120,
                  fillColor: const Color(0x334CAF50), // Verde translúcido
                  strokeWidth: 0,
                )).toSet(),
                myLocationEnabled: true,
                mapType: MapType.normal,
                style: _mapStyle,
              ),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Color(0xFFFC5200))),
              
              // Buscador Tropicalizado
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
                      hintText: "Buscar rutas seguras en la UAO...",
                      border: InputBorder.none,
                      icon: Icon(Icons.security, color: Colors.green),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final String _mapStyle = '''[ { "featureType": "all", "elementType": "labels.text.fill", "stylers": [ { "color": "#ffffff" } ] }, { "featureType": "all", "elementType": "labels.text.stroke", "stylers": [ { "color": "#000000" }, { "lightness": 13 } ] } ]''';
}