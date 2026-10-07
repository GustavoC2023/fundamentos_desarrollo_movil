import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'auth_page.dart';

class PerfilPage extends StatelessWidget {
  final AuthService authService;
  const PerfilPage({super.key, required this.authService});

  String get _nombre {
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    final n = meta?['nombre'] as String?;
    if (n != null && n.trim().isNotEmpty) return n;
    return 'Sin nombre';
  }

  String get _email =>
      Supabase.instance.client.auth.currentUser?.email ?? 'Sin correo';

  Future<void> _cerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await Supabase.instance.client.auth.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => AuthPage(authService: authService),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.amber.shade200,
              child: Text(
                _nombre.isNotEmpty ? _nombre[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.person_outline, color: Colors.amber.shade800),
              title: const Text('Nombre'),
              subtitle: Text(
                _nombre,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.email_outlined, color: Colors.amber.shade800),
              title: const Text('Correo'),
              subtitle: Text(
                _email,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _cerrarSesion(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}