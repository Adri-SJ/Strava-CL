import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../data/auth_repository.dart';

/// Pantalla encargada del registro de nuevos atletas en la plataforma.
/// Captura los datos iniciales y los envía al backend para la creación de la cuenta.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para la captura de datos del formulario
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  
  // Instancia del repositorio para la comunicación con la API en OCI
  final _authRepo = AuthRepository();

  /// Lógica para procesar el registro del usuario.
  /// Empaqueta los datos en un modelo 'User' y gestiona la respuesta asíncrona.
  void _handleRegister() async {
    // Creación del objeto de datos (Data Class) a partir de los inputs
    final newUser = User(
      username: _userController.text,
      email: _emailController.text,
      password: _passController.text,
    );

    // Llamada asíncrona al repositorio para persistencia en la base de datos remota
    final success = await _authRepo.registerUser(newUser);
    
    // Gestión de feedback visual basado en el resultado de la operación
    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Registro exitoso"), 
          backgroundColor: Colors.green
        ),
      );
      // Retorno automático a la pantalla de Login tras éxito
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error al registrar. Verifica tus datos."), 
          backgroundColor: Colors.red
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Únete a Strava Clone"),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Campo para el nombre de usuario o alias del atleta
            TextField(
              controller: _userController, 
              decoration: const InputDecoration(labelText: "Nombre de atleta")
            ),
            // Campo para el correo electrónico (identificador principal)
            TextField(
              controller: _emailController, 
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            // Campo de seguridad para la contraseña
            TextField(
              controller: _passController, 
              obscureText: true, 
              decoration: const InputDecoration(labelText: "Contraseña")
            ),
            const SizedBox(height: 30),
            
            // Botón de acción principal con el estilo visual de la marca
            ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC5200), // Naranja característico
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "REGISTRARME", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      ),
    );
  }
}