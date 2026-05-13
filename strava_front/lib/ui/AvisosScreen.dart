import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class AvisosScreen extends StatefulWidget {
  final int userId;
  const AvisosScreen({super.key, required this.userId});

  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  final AuthRepository _repo = AuthRepository();
  final TextEditingController _avisoCtrl = TextEditingController();
  String _categoriaSeleccionada = "Seguridad";

  void _enviarAviso() async {
    if (_avisoCtrl.text.isEmpty) return;
    bool ok = await _repo.publicarAviso(widget.userId, _avisoCtrl.text, _categoriaSeleccionada);
    if (ok) {
      _avisoCtrl.clear();
      setState(() {}); // Recarga la lista
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Aviso publicado!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tablero Comunitario UAO"), backgroundColor: Colors.black),
      body: Column(
        children: [
          // Área para escribir nuevo aviso
          Container(
            padding: const EdgeInsets.all(15),
            color: const Color(0xFF1F1F1F),
            child: Column(
              children: [
                TextField(
                  controller: _avisoCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "¿Qué quieres avisar a la comunidad?",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: _categoriaSeleccionada,
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.orange),
                      items: ["Seguridad", "Comunidad", "Evento"]
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => _categoriaSeleccionada = v!),
                    ),
                    ElevatedButton(
                      onPressed: _enviarAviso,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text("Publicar"),
                    )
                  ],
                )
              ],
            ),
          ),
          // Lista de avisos
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _repo.obtenerAvisos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final aviso = snapshot.data![i];
                    return Card(
                      color: const Color(0xFF2C2C2C),
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Icon(
                          aviso['categoria'] == 'Seguridad' ? Icons.warning : Icons.campaign,
                          color: aviso['categoria'] == 'Seguridad' ? Colors.red : Colors.green,
                        ),
                        title: Text(aviso['contenido'], style: const TextStyle(color: Colors.white)),
                        subtitle: Text("Categoría: ${aviso['categoria']}", style: const TextStyle(color: Colors.grey)),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}