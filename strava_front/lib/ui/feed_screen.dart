import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed de Actividades"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: const Color(0xFF121212),
        child: FutureBuilder<List<dynamic>>(
          future: AuthRepository().obtenerFeed(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFFC5200)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No hay rutas aún", style: TextStyle(color: Colors.white)));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final actividad = snapshot.data![index];
                return _buildActivityCard(actividad);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildActivityCard(dynamic actividad) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFFC5200), child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 10),
              Text(actividad['titulo'] ?? "Actividad", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 15),
          Text("Distancia: ${actividad['distancia_km']} km", style: const TextStyle(color: Colors.orangeAccent)),
          const SizedBox(height: 10),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Icon(Icons.map, color: Colors.white54, size: 50)),
          ),
        ],
      ),
    );
  }
}