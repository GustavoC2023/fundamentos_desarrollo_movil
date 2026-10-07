import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/usuarios_repository.dart';
import 'screens/auth_page.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zrmutlzvfrtstroaswim.supabase.co',
    anonKey: 'sb_publishable_QB9WdbmRbf481y66vFvsfA_ilwsy2Lh',
  );

  final authService = AuthService(UsuariosRepositorySupabase());
  runApp(PizzApp(authService: authService));
}

class PizzApp extends StatelessWidget {
  final AuthService authService;
  const PizzApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pizzap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
      ),
      home: AuthPage(authService: authService),
    );
  }
}