import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../data/auth_repository.dart';


class RegisterScreen extends StatefulWidget{

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _authRepo = AuthRepository();

  void _handleRegister() async {
    final newUser = User(
      username: _userController.text,
      email: _emailController.text,
      password: _passController.text,
    );

    final success = await _authRepo.registerUser(newUser);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Registro exitoso")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al registrar")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Únete a Strava Clone")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _userController, decoration: const InputDecoration(labelText: "Nombre de atleta")),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Contraseña")),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC5200),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("REGISTRARME", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

}
