import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../data/auth_repository.dart';

// --- EVENTOS ---
abstract class RecordEvent {}
class StartRecordingEvent extends RecordEvent { final String deporte; StartRecordingEvent(this.deporte); }
class PauseRecordingEvent extends RecordEvent {}
class ResumeRecordingEvent extends RecordEvent {}
class StopRecordingEvent extends RecordEvent {}
class _UpdatePositionEvent extends RecordEvent { final Position position; _UpdatePositionEvent(this.position); }
class _TickEvent extends RecordEvent {}

// --- ESTADO ---
class RecordState {
  final bool isRecording;
  final List<LatLng> ruta;
  final double distancia;
  final int segundos;
  final int? actividadId;

  RecordState({
    this.isRecording = false,
    this.ruta = const [],
    this.distancia = 0.0,
    this.segundos = 0,
    this.actividadId,
  });

  RecordState copyWith({bool? isRecording, List<LatLng>? ruta, double? distancia, int? segundos, int? actividadId}) {
    return RecordState(
      isRecording: isRecording ?? this.isRecording,
      ruta: ruta ?? this.ruta,
      distancia: distancia ?? this.distancia,
      segundos: segundos ?? this.segundos,
      actividadId: actividadId ?? this.actividadId,
    );
  }
}

// --- BLOC ---
class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final AuthRepository repository;
  StreamSubscription<Position>? _gpsSubscription;
  Timer? _timer;

  RecordBloc(this.repository) : super(RecordState()) {
    on<StartRecordingEvent>(_onStart);
    on<_UpdatePositionEvent>(_onUpdatePosition);
    on<_TickEvent>((event, emit) => emit(state.copyWith(segundos: state.segundos + 1)));
    on<StopRecordingEvent>(_onStop);
  }

  Future<void> _onStart(StartRecordingEvent event, emit) async {
    final id = await repository.crearActividad(event.deporte);
    if (id != null) {
      emit(state.copyWith(isRecording: true, actividadId: id, segundos: 0, distancia: 0, ruta: []));
      
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
    
    // Guardar en OCI
    repository.enviarPuntoGPS(state.actividadId!, nuevoPunto.latitude, nuevoPunto.longitude, nuevaLista.length);
    
    emit(state.copyWith(ruta: nuevaLista, distancia: nuevaDistancia));
  }

  void _onStop(StopRecordingEvent event, emit) {
    _timer?.cancel();
    _gpsSubscription?.cancel();
    emit(state.copyWith(isRecording: false));
  }
}