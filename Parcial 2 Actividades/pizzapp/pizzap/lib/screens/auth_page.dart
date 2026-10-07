import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'menu_page.dart';

class AuthPage extends StatefulWidget {
  final AuthService authService;
  const AuthPage({super.key, required this.authService});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  Future<void> _submit() async {
    setState(() => _error = null);

    bool ok;
    if (isLogin) {
      ok = await widget.authService.login(_email.text.trim(), _password.text);
    } else {
      ok = await widget.authService.registrar(
        _nombre.text.trim(),
        _email.text.trim(),
        _password.text,
      );
    }

    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MenuPage(authService: widget.authService), // ← cambio
        ),
      );
    } else {
      setState(() => _error = 'Credenciales incorrectas o campos vacíos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'pizzapp',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 40),
                if (!isLogin) ...[
                  TextField(
                    controller: _nombre,
                    decoration: const InputDecoration(
                      hintText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                    hintText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(isLogin ? 'Iniciar Sesión' : 'Crear Cuenta'),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? '¿No tienes cuenta? Regístrate'
                        : '¿Ya tienes cuenta? Inicia sesión',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Demo: demo@pizzapp.com / 1234',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}