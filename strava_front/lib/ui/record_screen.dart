import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  // Posición inicial (puedes usar coordenadas de Oaxaca)
  static const CameraPosition _initialPos = CameraPosition(
    target: LatLng(17.0654, -96.7236),
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grabar Ruta")),
      body: Column(
        children: [
          // 1. El Mapa (Ocupa la mayor parte)
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: _initialPos,
              myLocationEnabled: true, // Activa el punto azul del GPS
              zoomControlsEnabled: false,
            ),
          ),
          // 2. Panel de Control (Estilo de tu mockup)
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF1F1F1F),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat("00:00", "Tiempo"),
                  // Botón Rojo Circular de tu foto
                  GestureDetector(
                    onTap: () => print("Iniciando grabación..."),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                  _buildStat("0.00 km", "Distancia"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}