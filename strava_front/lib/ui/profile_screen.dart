import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../ui/activity_detail_screen.dart';

/// Pantalla de perfil personal del usuario ("Tú").
/// Centraliza el resumen estadístico y el historial histórico de rutas del usuario logueado.
class ProfileScreen extends StatefulWidget {
  final int userId; 
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _authRepo = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Tú", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      // FutureBuilder para obtener datos asíncronos filtrados por el ID de usuario
      body: FutureBuilder<List<dynamic>>(
        future: _authRepo.obtenerMisActividades(widget.userId),
        builder: (context, snapshot) {
          // Feedback visual mientras se resuelve la petición al servidor en OCI
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFC5200)));
          }

          final misRutas = snapshot.data ?? [];
          
          // Cálculo dinámico de métricas acumuladas mediante reducción de lista
          double totalKm = misRutas.fold(0.0, (sum, item) => sum + (item['distancia_km'] ?? 0.0));

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera de estadísticas rápidas: Kilómetros totales y conteo de actividades
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat("TOTAL KM", totalKm.toStringAsFixed(1)),
                      _buildStat("RUTAS", misRutas.length.toString()),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  const Text("Resumen de Esfuerzo", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Visualización de datos: Gráfica de Barras Generativa
                  // Representa la magnitud de las últimas 7 actividades para dar feedback de progreso
                  Container(
                    height: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        double altura = 10.0;
                        if (index < misRutas.length) {
                          // Escalado proporcional de la altura de barra según distancia
                          altura = (misRutas[index]['distancia_km'] ?? 1.0) * 10.0;
                        }
                        return Container(
                          width: 25,
                          height: altura > 100 ? 100 : altura, // Límite visual para diseño
                          decoration: BoxDecoration(
                            color: const Color(0xFFFC5200),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  const Text("Historial de Actividades", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  // Implementación de ListView para el historial de rutas personales
                  ListView.builder(
                    shrinkWrap: true, // Permite que la lista coexista dentro de un SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: misRutas.length,
                    itemBuilder: (context, index) {
                      final ruta = misRutas[index];
                      return GestureDetector(
                        onTap: () {
                          // Navegación contextual al detalle enviando el objeto completo de la ruta
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityDetailScreen(actividad: ruta),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: const Color(0xFF1F1F1F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: const Icon(Icons.directions_run, color: Color(0xFFFC5200)),
                            ),
                            title: Text(
                              ruta['titulo'] ?? "Carrera",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${ruta['distancia_km']?.toStringAsFixed(2)} km • ${ruta['fecha']?.substring(0,10)}", 
                              style: const TextStyle(color: Colors.grey)
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                          ),
                        )
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Helper para la construcción de etiquetas de estadísticas uniformes
  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  }
}