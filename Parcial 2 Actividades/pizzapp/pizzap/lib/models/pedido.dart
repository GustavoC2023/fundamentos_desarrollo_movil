import 'item_pedido.dart';

class Pedido {
  final int? id;
  final String usuarioEmail;
  final String direccion;
  final List<ItemPedido> items;
  final DateTime fecha;
  final String estado;

  Pedido({
    this.id,
    required this.usuarioEmail,
    required this.direccion,
    required this.items,
    DateTime? fecha,
    this.estado = 'pendiente',
  }) : fecha = fecha ?? DateTime.now();

  double get total => items.fold(0, (s, i) => s + i.subtotal);

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
        id: json['id'],
        usuarioEmail: json['usuario_email'],
        direccion: json['direccion'],
        items: (json['items'] as List)
            .map((e) => ItemPedido.fromJson(e))
            .toList(),
        fecha: DateTime.parse(json['fecha']),
        estado: json['estado'] ?? 'pendiente',
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'usuario_email': usuarioEmail,
        'direccion': direccion,
        'items': items.map((e) => e.toJson()).toList(),
        'fecha': fecha.toIso8601String(),
        'estado': estado,
      };
}