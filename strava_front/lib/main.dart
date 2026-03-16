import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Importante
import 'ui/welcome_screen.dart';
import 'blocs/record_bloc.dart'; // Asegúrate de crear este archivo
import 'data/auth_repository.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Inyectamos el Bloc de grabación globalmente
        BlocProvider(
          create: (context) => RecordBloc(AuthRepository()),
        ),
      ],
      child: MaterialApp(
        home: const WelcomeScreen(),
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFFC5200),
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1F1F1F)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC5200),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}