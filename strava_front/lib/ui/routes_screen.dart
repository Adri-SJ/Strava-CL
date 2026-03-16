import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Rutas", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, size: 20)),
        ),
      ),
      body: Stack(
        children: [
          // Mapa de fondo
          const GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(17.0654, -96.7236), zoom: 14),
            zoomControlsEnabled: false,
          ),
          // Buscador (Fidelidad visual al mockup 4)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.black),
                  hintText: "Buscar rutas...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}