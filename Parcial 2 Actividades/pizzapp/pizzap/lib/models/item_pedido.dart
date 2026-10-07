import 'pizza.dart';

class ItemPedido {
  final Pizza pizza;
  final TamanoPizza tamano;
  final int cantidad;
  final List<String> ingredientesExtra;
  final bool orillaRellena;

  ItemPedido({
    required this.pizza,
    required this.tamano,
    this.cantidad = 1,
    this.ingredientesExtra = const [],
    this.orillaRellena = false,
  });

  double get precioUnitario {
    double p = pizza.precioPara(tamano);
    p += ingredientesExtra.length * 15.0;
    if (orillaRellena) p += 30.0;
    return p;
  }

  double get subtotal => precioUnitario * cantidad;

  String get resumen {
    final extras = ingredientesExtra.isEmpty
        ? ''
        : ' + ${ingredientesExtra.join(', ')}';
    final orilla = orillaRellena ? ' + orilla rellena' : '';
    return '${pizza.nombre} (${tamano.label})$extras$orilla';
  }

  factory ItemPedido.fromJson(Map<String, dynamic> json) => ItemPedido(
        pizza: Pizza.fromJson(json['pizza']),
        tamano: json['tamano'] == 'grande'
            ? TamanoPizza.grande
            : TamanoPizza.mediana,
        cantidad: json['cantidad'] ?? 1,
        ingredientesExtra:
            List<String>.from(json['ingredientes_extra'] ?? []),
        orillaRellena: json['orilla_rellena'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'pizza': pizza.toJson(),
        'tamano': tamano == TamanoPizza.grande ? 'grande' : 'mediana',
        'cantidad': cantidad,
        'ingredientes_extra': ingredientesExtra,
        'orilla_rellena': orillaRellena,
      };
}