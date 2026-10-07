class Usuario {
  final int? id;
  final String nombre;
  final String email;
  final String password;

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'],
        nombre: json['nombre'] ?? '',
        email: json['email'],
        password: json['password'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'email': email,
        'password': password,
      };
}