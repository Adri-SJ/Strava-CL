import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http; // Necesario para la petición rápida de seguridad
import '../blocs/record_bloc.dart';
import '../blocs/record_state.dart';
import '../data/auth_repository.dart';

class RecordScreen extends StatefulWidget {
  final int userId;
  const RecordScreen({super.key, required this.userId});
  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  GoogleMapController? _mapController; 
  String _deporteSeleccionado = "Caminata";
  final AuthRepository _authRepo = AuthRepository();

  String _formatearTiempo(int segundos) {
    int mins = segundos ~/ 60;
    int secs = segundos % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  void _mostrarDialogoFinalizar(RecordState state) {
    TextEditingController nombreCtrl = TextEditingController(text: "Ruta por la Anáhuac");
    TextEditingController mensajeCtrl = TextEditingController();
    int nivelSeguridad = 3; // Valor inicial de tropicalización

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        // StatefulBuilder permite actualizar las estrellitas sin cerrar el diálogo
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                    const SizedBox(height: 15),
                    
                    // --- SECCIÓN TROPICALIZADA: CALIFICACIÓN DE SEGURIDAD ---
                    const Text("¿Qué tan segura sentiste la zona?", 
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < nivelSeguridad ? Icons.shield : Icons.shield_outlined,
                            color: index < nivelSeguridad ? Colors.green : Colors.grey,
                          ),
                          onPressed: () => setDialogState(() => nivelSeguridad = index + 1),
                        );
                      }),
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
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text("Descartar", style: TextStyle(color: Colors.red))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () async {
                    if (state.actividadId != null) {
                      // 1. Finalizar actividad normal
                      await _authRepo.finalizarActividad(
                        state.actividadId!,
                        nombreCtrl.text,
                        mensajeCtrl.text,
                        state.distancia,
                        state.imagePath,
                      );

                      // 2. Enviar calificación de seguridad al nuevo endpoint de OCI
                      try {
                        await http.put(
                          Uri.parse("http://159.54.147.165:8000/actividades/${state.actividadId}/seguridad?nivel=$nivelSeguridad")
                        );
                      } catch (e) {
                        print("Error al sincronizar seguridad: $e");
                      }
                    }
                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(context, '/feed', (route) => false);
                    }
                  },
                  child: const Text("Publicar en Feed"),
                )
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecordBloc, RecordState>(
      listener: (context, state) {
        if (state.ruta.isNotEmpty && _mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLng(state.ruta.last));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text("Grabar Ruta Anáhuac"),
            actions: [
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
              Expanded(
                flex: 3,
                child: GoogleMap(
                  onMapCreated: (c) => _mapController = c,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(17.0041, -96.7112), // CENTRADO EN CAMPUS UAO
                    zoom: 16
                  ),
                  myLocationEnabled: true,
                  // CAPA DE CALOR: Muestra zonas seguras reportadas por la comunidad
                  circles: state.puntosSeguros.map((punto) => Circle(
                    circleId: CircleId("seguro_${punto.latitude}_${punto.longitude}"),
                    center: punto,
                    radius: 120,
                    fillColor: const Color(0x334CAF50), // Verde translúcido
                    strokeWidth: 0,
                  )).toSet(),
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
              Container(
                height: 180,
                color: const Color(0xFF1F1F1F),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statColumn(_formatearTiempo(state.segundos), "Tiempo"),
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

  Widget _statColumn(String v, String l) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(v, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      Text(l, style: const TextStyle(color: Colors.grey, fontSize: 14)),
    ]);
  }
}