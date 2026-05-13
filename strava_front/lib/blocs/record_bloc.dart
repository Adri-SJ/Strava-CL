import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../data/auth_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'record_state.dart';

abstract class RecordEvent {}

class StartRecordingEvent extends RecordEvent { 
  final String deporte; 
  final int userId; 
  StartRecordingEvent(this.deporte, this.userId); 
}

class StopRecordingEvent extends RecordEvent {}

class _UpdatePositionEvent extends RecordEvent { 
  final Position position; 
  _UpdatePositionEvent(this.position); 
}

class _TickEvent extends RecordEvent {}

class PickImageEvent extends RecordEvent { 
  final bool fromCamera; 
  PickImageEvent(this.fromCamera); 
}

// NUEVO EVENTO: Carga zonas seguras
class LoadSecurityHeatmapEvent extends RecordEvent {}

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final AuthRepository repository;
  StreamSubscription<Position>? _gpsSubscription;
  Timer? _timer;

  RecordBloc(this.repository) : super(RecordState()) {
    on<StartRecordingEvent>(_onStart);
    on<_UpdatePositionEvent>(_onUpdatePosition);
    on<_TickEvent>((event, emit) => emit(state.copyWith(segundos: state.segundos + 1)));
    on<StopRecordingEvent>(_onStop);
    on<PickImageEvent>(_onPickImage);
    // Manejador para el mapa de calor
    on<LoadSecurityHeatmapEvent>(_onLoadHeatmap);
  }

  Future<void> _onLoadHeatmap(LoadSecurityHeatmapEvent event, emit) async {
    final puntos = await repository.obtenerPuntosSeguros();
    emit(state.copyWith(puntosSeguros: puntos));
  }

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
      
      _timer = Timer.periodic(const Duration(seconds: 1), (t) => add(_TickEvent()));
      
      _gpsSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5)
      ).listen((pos) => add(_UpdatePositionEvent(pos)));
    }
  }

  void _onUpdatePosition(_UpdatePositionEvent event, emit) {
    if (!state.isRecording) return;
    final nuevoPunto = LatLng(event.position.latitude, event.position.longitude);
    double nuevaDistancia = state.distancia;

    if (state.ruta.isNotEmpty) {
      nuevaDistancia += Geolocator.distanceBetween(
        state.ruta.last.latitude, state.ruta.last.longitude,
        nuevoPunto.latitude, nuevoPunto.longitude
      ) / 1000;
    }

    final nuevaLista = List<LatLng>.from(state.ruta)..add(nuevoPunto);
    repository.enviarPuntoGPS(state.actividadId!, nuevoPunto.latitude, nuevoPunto.longitude, nuevaLista.length);
    emit(state.copyWith(ruta: nuevaLista, distancia: nuevaDistancia));
  }

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

  void _onStop(StopRecordingEvent event, emit) {
    _timer?.cancel();
    _gpsSubscription?.cancel();
    emit(state.copyWith(isRecording: false));
  }
}