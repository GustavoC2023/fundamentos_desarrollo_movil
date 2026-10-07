import '../data/usuarios_repository.dart';
import '../models/usuario.dart';

class AuthService {
  final UsuariosRepository _repo;

  AuthService(this._repo);

  Usuario? _usuarioActual;
  Usuario? get usuarioActual => _usuarioActual;
  bool get estaLogueado => _usuarioActual != null;

  Future<bool> login(String email, String password) async {
    final u = await _repo.login(email, password);
    _usuarioActual = u;
    return u != null;
  }

  Future<bool> registrar(String nombre, String email, String password) async {
    if (nombre.isEmpty || email.isEmpty || password.isEmpty) return false;
    final u = await _repo.registrar(
      Usuario(nombre: nombre, email: email, password: password),
    );
    _usuarioActual = u;
    return true;
  }

  void logout() {
    _usuarioActual = null;
  }
}