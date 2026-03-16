import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Tú", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings))],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Resumen Semanal", 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Simulación de Gráfica de Barras (Naranja Strava)
              Container(
                height: 150,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) => Container(
                    width: 20,
                    height: (index + 1) * 15.0, // Alturas variadas
                    decoration: BoxDecoration(
                      color: const Color(0xFFFC5200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
              ),
              
              const SizedBox(height: 30),
              const Text("Actividades", 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              // Simulación de Calendario / Lista de historial
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFF1F1F1F),
                    child: ListTile(
                      leading: const Icon(Icons.directions_run, color: Color(0xFFFC5200)),
                      title: Text("Carrera matutina ${index + 1}"),
                      subtitle: const Text("5.2 km • 25 min", style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}