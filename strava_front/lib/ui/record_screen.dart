import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../data/auth_repository.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});
  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final AuthRepository _authRepo = AuthRepository();
  
  // --- ESTADO DE LA ACTIVIDAD ---
  int? _actividadId;
  bool _isRecording = false;
  int _puntosContador = 0;
  String _deporteSeleccionado = "Caminata";
  
  // --- VARIABLES PARA UI Y MAPA ---
  Timer? _timer;
  int _segundos = 0;
  double _distanciaTotal = 0.0;
  final List<LatLng> _rutaPuntos = [];
  Set<Polyline> _polylines = {};
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  String _formatearTiempo(int segundos) {
    int mins = segundos ~/ 60;
    int secs = segundos % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  void _iniciarCronometro() {
    _segundos = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording) {
        setState(() => _segundos++);
      }
    });
  }

  void _toggleRecording() async {
    if (!_isRecording) {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      // Iniciar actividad en OCI
      final id = await _authRepo.crearActividad(_deporteSeleccionado);
      if (id != null) {
        _iniciarCronometro();
        setState(() {
          _actividadId = id;
          _isRecording = true;
          _puntosContador = 0;
          _distanciaTotal = 0.0;
          _rutaPuntos.clear();
          _polylines.clear();
        });
        _startGpsStream();
      }
    } else {
      // Detener grabación
      _timer?.cancel();
      setState(() => _isRecording = false);
      _mostrarDialogoFinalizar();
    }
  }

  void _startGpsStream() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Cada 5 metros
      )
    ).listen((Position position) {
      if (_isRecording && _actividadId != null) {
        LatLng nuevoPunto = LatLng(position.latitude, position.longitude);
        
        // Calcular distancia acumulada en Km
        if (_rutaPuntos.isNotEmpty) {
          double metros = Geolocator.distanceBetween(
            _rutaPuntos.last.latitude, _rutaPuntos.last.longitude,
            position.latitude, position.longitude
          );
          _distanciaTotal += metros / 1000;
        }

        _rutaPuntos.add(nuevoPunto);
        
        // Mover cámara automáticamente
        _mapController?.animateCamera(CameraUpdate.newLatLng(nuevoPunto));

        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId("mi_ruta"),
              points: _rutaPuntos,
              color: Colors.orange,
              width: 6,
            )
          };
        });

        // Enviar coordenadas a PostgreSQL
        _authRepo.enviarPuntoGPS(
          _actividadId!, 
          position.latitude, 
          position.longitude, 
          _puntosContador++
        );
      }
    });
  }

  void _mostrarDialogoFinalizar() {
    TextEditingController nombreCtrl = TextEditingController(text: "Ruta por Oaxaca");
    TextEditingController mensajeCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text("¡Ruta Terminada!", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nombre de la ruta",
                labelStyle: TextStyle(color: Colors.orange),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: mensajeCtrl,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "¿Qué tal estuvo el entrenamiento?",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Descartar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              // 1. Guardar nombre y mensaje en OCI antes de salir
              if (_actividadId != null) {
                await _authRepo.finalizarActividad(
                  _actividadId!, 
                  nombreCtrl.text, 
                  mensajeCtrl.text, 
                  _distanciaTotal
                );
              }

              if (mounted) {
                Navigator.pop(context); // Cierra el diálogo
                Navigator.of(context).pop(); // Regresa al Feed
              }
            },
            child: const Text("Publicar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, 
        title: const Text("Grabar Ruta", style: TextStyle(color: Colors.white)),
        actions: [
          if (!_isRecording)
            DropdownButton<String>(
              value: _deporteSeleccionado,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.orange),
              underline: Container(),
              items: ["Caminata", "Running", "Ciclismo"].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) => setState(() => _deporteSeleccionado = val!),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: const CameraPosition(
                target: LatLng(17.0654, -96.7236), 
                zoom: 16
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              polylines: _polylines,
            ),
          ),
          Container(
            height: 180,
            color: const Color(0xFF1F1F1F),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(_deporteSeleccionado, style: const TextStyle(color: Colors.grey)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statColumn(_formatearTiempo(_segundos), "Tiempo"),
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                        width: 85, height: 85,
                        decoration: BoxDecoration(
                          color: _isRecording ? Colors.orange : Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.play_arrow, 
                          color: Colors.white, 
                          size: 45
                        ),
                      ),
                    ),
                    _statColumn("${_distanciaTotal.toStringAsFixed(2)} km", "Distancia"),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}