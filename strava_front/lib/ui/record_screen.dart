import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../blocs/record_bloc.dart';
import '../data/auth_repository.dart';

/// Pantalla interactiva para la grabación de rutas en tiempo real.
/// Gestiona la visualización del mapa dinámico, cronómetro y persistencia de la actividad final.
class RecordScreen extends StatefulWidget {
  final int userId;
  const RecordScreen({super.key, required this.userId});
  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  GoogleMapController? _mapController; // Controlador para manipular la cámara del mapa
  String _deporteSeleccionado = "Caminata";
  final AuthRepository _authRepo = AuthRepository();

  /// Convierte el total de segundos en un formato legible MM:SS
  String _formatearTiempo(int segundos) {
    int mins = segundos ~/ 60;
    int secs = segundos % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  /// Despliega un modal al detener la grabación para capturar metadatos finales y fotos.
  void _mostrarDialogoFinalizar(RecordState state) {
    TextEditingController nombreCtrl = TextEditingController(text: "Ruta por Oaxaca");
    TextEditingController mensajeCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Fuerza al usuario a decidir si publica o descarta
      builder: (context) => BlocBuilder<RecordBloc, RecordState>(
        builder: (context, state) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1F1F1F),
            title: const Text("¡Ruta Terminada!", style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Nombre de la ruta", 
                      labelStyle: TextStyle(color: Colors.orange)
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: mensajeCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "¿Cómo estuvo tu recorrido?", 
                      hintStyle: TextStyle(color: Colors.grey)
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Visualización previa de la imagen capturada durante la ruta
                  state.imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(state.imagePath!), height: 120, width: double.infinity, fit: BoxFit.cover),
                        )
                      : Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.image, color: Colors.grey, size: 50),
                        ),
                  
                  const SizedBox(height: 10),
                  // Acciones para adjuntar evidencia multimedia
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.orange),
                        onPressed: () => context.read<RecordBloc>().add(PickImageEvent(true)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.orange),
                        onPressed: () => context.read<RecordBloc>().add(PickImageEvent(false)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Descartar")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () async {
                  if (state.actividadId != null) {
                    // Sincronización final con el servidor incluyendo metadatos y archivos binarios
                    await _authRepo.finalizarActividad(
                      state.actividadId!,
                      nombreCtrl.text,
                      mensajeCtrl.text,
                      state.distancia,
                      state.imagePath,
                    );
                  }
                  if (mounted) {
                    Navigator.pop(context); // Cierra el modal
                    // Retorno al feed principal limpiando el stack de navegación
                    Navigator.pushNamedAndRemoveUntil(context, '/feed', (route) => false);
                  }
                },
                child: const Text("Publicar en el Feed"),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecordBloc, RecordState>(
      // Listener para mover automáticamente la cámara conforme el usuario se desplaza
      listener: (context, state) {
        if (state.ruta.isNotEmpty && _mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLng(state.ruta.last));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text("Grabar Ruta"),
            actions: [
              // Selector de modalidad deportiva activo solo antes de iniciar la grabación
              if (!state.isRecording)
                DropdownButton<String>(
                  value: _deporteSeleccionado,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.orange),
                  items: ["Caminata", "Running", "Ciclismo"]
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (val) => setState(() => _deporteSeleccionado = val!),
                ),
            ],
          ),
          body: Column(
            children: [
              // Área del mapa con renderizado de polilínea en tiempo real
              Expanded(
                flex: 3,
                child: GoogleMap(
                  onMapCreated: (c) => _mapController = c,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(17.0654, -96.7236), // Coordenadas iniciales (Oaxaca)
                    zoom: 16
                  ),
                  myLocationEnabled: true,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("m"), 
                      points: state.ruta, 
                      color: Colors.orange, 
                      width: 6
                    )
                  },
                ),
              ),
              // Panel inferior de control y métricas
              Container(
                height: 180,
                color: const Color(0xFF1F1F1F),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statColumn(_formatearTiempo(state.segundos), "Tiempo"),
                    // Botón de acción principal: Alterna entre Start/Stop de la grabación
                    GestureDetector(
                      onTap: () {
                        if (!state.isRecording) {
                          context.read<RecordBloc>().add(StartRecordingEvent(_deporteSeleccionado, widget.userId));
                        } else {
                          context.read<RecordBloc>().add(StopRecordingEvent());
                          _mostrarDialogoFinalizar(state);
                        }
                      },
                      child: Container(
                        width: 85, height: 85,
                        decoration: BoxDecoration(
                          color: state.isRecording ? Colors.orange : Colors.red, 
                          shape: BoxShape.circle
                        ),
                        child: Icon(
                          state.isRecording ? Icons.stop : Icons.play_arrow, 
                          color: Colors.white, 
                          size: 45
                        ),
                      ),
                    ),
                    _statColumn("${state.distancia.toStringAsFixed(2)} km", "Distancia"),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper para maquetar columnas de estadísticas (Tiempo, Distancia, etc.)
  Widget _statColumn(String v, String l) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(v, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      Text(l, style: const TextStyle(color: Colors.grey, fontSize: 14)),
    ]);
  }
}