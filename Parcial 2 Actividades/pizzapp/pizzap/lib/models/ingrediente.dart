class Ingrediente {
  final int? id;
  final String nombre;
  final double precioExtra;

  Ingrediente({
    this.id,
    required this.nombre,
    this.precioExtra = 15.0,
  });

  factory Ingrediente.fromJson(Map<String, dynamic> json) => Ingrediente(
        id: json['id'],
        nombre: json['nombre'],
        precioExtra: (json['precio_extra'] as num?)?.toDouble() ?? 15.0,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'precio_extra': precioExtra,
      };
}