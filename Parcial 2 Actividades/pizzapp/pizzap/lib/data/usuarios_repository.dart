import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';

abstract class UsuariosRepository {
  Future<Usuario?> login(String email, String password);
  Future<Usuario> registrar(Usuario usuario);
}

/// Implementación local (en memoria) — la que ya tenías.
/// Se queda aquí por si algún día quieres usarla para pruebas.
class UsuariosRepositoryLocal implements UsuariosRepository {
  final List<Usuario> _usuarios = [
    Usuario(id: 1, nombre: 'Demo', email: 'demo@pizzapp.com', password: '1234'),
  ];

  @override
  Future<Usuario?> login(String email, String password) async {
    try {
      return _usuarios.firstWhere(
        (u) => u.email == email && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Usuario> registrar(Usuario usuario) async {
    final nuevo = Usuario(
      id: _usuarios.length + 1,
      nombre: usuario.nombre,
      email: usuario.email,
      password: usuario.password,
    );
    _usuarios.add(nuevo);
    return nuevo;
  }
}

/// Implementación con Supabase Auth.
class UsuariosRepositorySupabase implements UsuariosRepository {
  final _auth = Supabase.instance.client.auth;

  @override
  Future<Usuario?> login(String email, String password) async {
    try {
      final res = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) return null;
      return Usuario(
        id: null,
        nombre: (res.user!.userMetadata?['nombre'] as String?) ?? '',
        email: res.user!.email ?? email,
        password: '',
      );
    } on AuthException catch (e) {
      print('Error login: ${e.message}');
      return null;
    }
  }

  @override
  Future<Usuario> registrar(Usuario usuario) async {
    final res = await _auth.signUp(
      email: usuario.email,
      password: usuario.password,
      data: {'nombre': usuario.nombre},
    );
    if (res.user == null) {
      throw Exception('No se pudo registrar');
    }
    return Usuario(
      id: null,
      nombre: usuario.nombre,
      email: res.user!.email ?? usuario.email,
      password: '',
    );
  }
}