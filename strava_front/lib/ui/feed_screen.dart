import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, size: 20)),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFF121212), // Fondo oscuro
        child: ListView.builder(
          itemCount: 5, // Simulamos 5 actividades
          itemBuilder: (context, index) {
            return _buildActivityCard();
          },
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
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
          const Row(
            children: [
              CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person)),
              SizedBox(width: 10),
              Text("Usuario", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 15),
          // Placeholder para el mapa estático de tu mockup
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: AssetImage('assets/map_placeholder.png'), // Tu mapa de Canva
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.white24),
          ),
        ],
      ),
    );
  }
}