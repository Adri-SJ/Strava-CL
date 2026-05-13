import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecordState {
  final bool isRecording;
  final List<LatLng> ruta;
  final double distancia;
  final int segundos;
  final int? actividadId;
  final String? imagePath;
  final List<LatLng> puntosSeguros;

  RecordState({
    this.isRecording = false,
    this.ruta = const [],
    this.distancia = 0.0,
    this.segundos = 0,
    this.actividadId,
    this.imagePath,
    this.puntosSeguros = const [], 
  });

  RecordState copyWith({
    bool? isRecording,
    List<LatLng>? ruta,
    double? distancia,
    int? segundos,
    int? actividadId,
    String? imagePath,
    List<LatLng>? puntosSeguros,
  }) {
    return RecordState(
      isRecording: isRecording ?? this.isRecording,
      ruta: ruta ?? this.ruta,
      distancia: distancia ?? this.distancia,
      segundos: segundos ?? this.segundos,
      actividadId: actividadId ?? this.actividadId,
      imagePath: imagePath ?? this.imagePath,
      puntosSeguros: puntosSeguros ?? this.puntosSeguros,
    );
  }
}