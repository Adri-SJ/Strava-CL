import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../data/auth_repository.dart';
import 'package:image_picker/image_picker.dart';

// --- EVENTOS ---
// Definición de las acciones que pueden disparar cambios en el estado de grabación
abstract class RecordEvent {}

// Inicia la grabación de una actividad vinculada a un usuario específico
class StartRecordingEvent extends RecordEvent { 
  final String deporte; 
  final int userId; 
  StartRecordingEvent(this.deporte, this.userId); 
}

// Detiene los flujos de datos y finaliza la sesión actual
class StopRecordingEvent extends RecordEvent {}

// Evento interno para procesar cambios de ubicación enviados por el sensor GPS
class _UpdatePositionEvent extends RecordEvent { 
  final Position position; 
  _UpdatePositionEvent(this.position); 
}

// Incremento periódico del cronómetro
class _TickEvent extends RecordEvent {}

// Captura o selección de imagen para la actividad
class PickImageEvent extends RecordEvent { 
  final bool fromCamera; 
  PickImageEvent(this.fromCamera); 
}

// --- ESTADO ---
// Representación inmutable de la información de la actividad en progreso
class RecordState {
  final bool isRecording;      // Controla si el seguimiento está activo
  final List<LatLng> ruta;     // Listado de coordenadas para dibujar la polilínea en el mapa
  final double distancia;      // Acumulado de distancia en kilómetros
  final int segundos;          // Tiempo transcurrido
  final int? actividadId;      // ID de referencia devuelto por el backend (OCI)
  final String? imagePath;     // Ruta local de la foto seleccionada

  RecordState({
    this.isRecording = false,
    this.ruta = const [],
    this.distancia = 0.0,
    this.segundos = 0,
    this.actividadId,
    this.imagePath
  });

  // Método para generar nuevos estados manteniendo la inmutabilidad
  RecordState copyWith({
    bool? isRecording, 
    List<LatLng>? ruta, 
    double? distancia, 
    int? segundos, 
    int? actividadId,
    String? imagePath,
  }) {
    return RecordState(
      isRecording: isRecording ?? this.isRecording,
      ruta: ruta ?? this.ruta,
      distancia: distancia ?? this.distancia,
      segundos: segundos ?? this.segundos,
      actividadId: actividadId ?? this.actividadId,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

// --- BLOC ---
// Lógica de negocio para el seguimiento de actividad y sincronización con el servidor
class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final AuthRepository repository;
  StreamSubscription<Position>? _gpsSubscription; // Suscripción activa al sensor de ubicación
  Timer? _timer;                                  // Timer para el cronómetro

  RecordBloc(this.repository) : super(RecordState()) {
    on<StartRecordingEvent>(_onStart);
    on<_UpdatePositionEvent>(_onUpdatePosition);
    on<_TickEvent>((event, emit) => emit(state.copyWith(segundos: state.segundos + 1)));
    on<StopRecordingEvent>(_onStop);
    on<PickImageEvent>(_onPickImage);
  }

  // Crea la actividad en el backend e inicializa los flujos de tiempo y GPS
  Future<void> _onStart(StartRecordingEvent event, emit) async {
    final id = await repository.crearActividad(event.deporte, event.userId);
    if (id != null) {
      emit(state.copyWith(
        isRecording: true, 
        actividadId: id, 
        segundos: 0, 
        distancia: 0, 
        ruta: [],
        imagePath: null
      ));
      
      // Inicio del contador de tiempo
      _timer = Timer.periodic(const Duration(seconds: 1), (t) => add(_TickEvent()));
      
      // Configuración del stream de ubicación: Alta precisión y filtro de movimiento de 5 metros
      _gpsSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5)
      ).listen((pos) => add(_UpdatePositionEvent(pos)));
    }
  }

  // Procesa cada nueva coordenada, calcula la distancia acumulada y sincroniza con la API
  void _onUpdatePosition(_UpdatePositionEvent event, emit) {
    if (!state.isRecording) return;
    
    final nuevoPunto = LatLng(event.position.latitude, event.position.longitude);
    double nuevaDistancia = state.distancia;

    // Cálculo de distancia entre el último punto y el actual usando Haversine
    if (state.ruta.isNotEmpty) {
      nuevaDistancia += Geolocator.distanceBetween(
        state.ruta.last.latitude, state.ruta.last.longitude,
        nuevoPunto.latitude, nuevoPunto.longitude
      ) / 1000;
    }

    final nuevaLista = List<LatLng>.from(state.ruta)..add(nuevoPunto);
    
    // Sincronización inmediata de la coordenada al servidor para persistencia
    repository.enviarPuntoGPS(state.actividadId!, nuevoPunto.latitude, nuevoPunto.longitude, nuevaLista.length);
    
    emit(state.copyWith(ruta: nuevaLista, distancia: nuevaDistancia));
  }

  // Manejo de la cámara/galería mediante image_picker con compresión al 50%
  Future<void> _onPickImage(PickImageEvent event, emit) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: event.fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50,
    );
    if (photo != null) {
      emit(state.copyWith(imagePath: photo.path));
    }
  }

  // Limpieza de recursos y cierre de suscripciones para evitar memory leaks
  void _onStop(StopRecordingEvent event, emit) {
    _timer?.cancel();
    _gpsSubscription?.cancel();
    emit(state.copyWith(isRecording: false));
  }
}