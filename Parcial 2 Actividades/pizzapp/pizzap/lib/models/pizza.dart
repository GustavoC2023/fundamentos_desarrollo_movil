import 'ingrediente.dart';

enum TamanoPizza { mediana, grande }

extension TamanoPizzaExt on TamanoPizza {
  String get label => this == TamanoPizza.mediana ? 'Mediana' : 'Grande';
}

class Pizza {
  final int? id;
  final String nombre;
  final String descripcion;
  final double precioMediana;
  final double precioGrande;
  final List<String> ingredientes;
  final bool esPersonalizada;
  final String emoji;

  Pizza({
    this.id,
    required this.nombre,
    this.descripcion = '',
    required this.precioMediana,
    required this.precioGrande,
    required this.ingredientes,
    this.esPersonalizada = false,
    this.emoji = '🍕',
  });

  double precioPara(TamanoPizza tamano) =>
      tamano == TamanoPizza.mediana ? precioMediana : precioGrande;

  factory Pizza.fromJson(Map<String, dynamic> json) => Pizza(
        id: json['id'],
        nombre: json['nombre'],
        descripcion: json['descripcion'] ?? '',
        precioMediana: (json['precio_mediana'] as num).toDouble(),
        precioGrande: (json['precio_grande'] as num).toDouble(),
        ingredientes: List<String>.from(json['ingredientes'] ?? []),
        esPersonalizada: json['es_personalizada'] ?? false,
        emoji: json['emoji'] ?? '🍕',
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'precio_mediana': precioMediana,
        'precio_grande': precioGrande,
        'ingredientes': ingredientes,
        'es_personalizada': esPersonalizada,
        'emoji': emoji,
      };
}