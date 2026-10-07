import 'package:flutter/material.dart';
import '../models/ingrediente.dart';
import '../models/item_pedido.dart';
import '../models/pizza.dart';
import '../services/carrito_service.dart';

class PersonalizarPizzaPage extends StatefulWidget {
  final Pizza pizza;
  final CarritoService carrito;
  final List<Ingrediente> ingredientesDisponibles;

  const PersonalizarPizzaPage({
    super.key,
    required this.pizza,
    required this.carrito,
    this.ingredientesDisponibles = const [],
  });

  @override
  State<PersonalizarPizzaPage> createState() => _PersonalizarPizzaPageState();
}

class _PersonalizarPizzaPageState extends State<PersonalizarPizzaPage> {
  TamanoPizza _tamano = TamanoPizza.mediana;
  int _cantidad = 1;
  bool _orillaRellena = false;
  final Set<String> _extrasSeleccionados = {};

  static const _extrasBase = ['Pepperoni', 'Champiñones', 'Carne', 'Salchicha', 'Pimiento'];

  List<String> get _extras {
    if (widget.ingredientesDisponibles.isNotEmpty) {
      return widget.ingredientesDisponibles.map((e) => e.nombre).toList();
    }
    return _extrasBase;
  }

  double get _precioUnitario {
    double p = widget.pizza.precioPara(_tamano);
    p += _extrasSeleccionados.length * 15.0;
    if (_orillaRellena) p += 30.0;
    return p;
  }

  double get _subtotal => _precioUnitario * _cantidad;

  void _agregar() {
    final item = ItemPedido(
      pizza: widget.pizza,
      tamano: _tamano,
      cantidad: _cantidad,
      ingredientesExtra: _extrasSeleccionados.toList(),
      orillaRellena: _orillaRellena,
    );
    widget.carrito.agregar(item);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.resumen} agregado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pizza.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.pizza.descripcion,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          const Text('Tamaño', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<TamanoPizza>(
            segments: const [
              ButtonSegment(
                value: TamanoPizza.mediana,
                label: Text('Mediana'),
              ),
              ButtonSegment(
                value: TamanoPizza.grande,
                label: Text('Grande'),
              ),
            ],
            selected: {_tamano},
            onSelectionChanged: (s) => setState(() => _tamano = s.first),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ingredientes extra (+\$15 c/u)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._extras.map(
            (e) => CheckboxListTile(
              title: Text(e),
              value: _extrasSeleccionados.contains(e),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _extrasSeleccionados.add(e);
                  } else {
                    _extrasSeleccionados.remove(e);
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Orilla rellena de queso (+\$30)'),
            value: _orillaRellena,
            onChanged: (v) => setState(() => _orillaRellena = v),
          ),
          const SizedBox(height: 24),
          const Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _cantidad > 1
                    ? () => setState(() => _cantidad--)
                    : null,
              ),
              Text('$_cantidad', style: const TextStyle(fontSize: 20)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => _cantidad++),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Subtotal: \$${_subtotal.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Agregar al carrito'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _agregar,
          ),
        ],
      ),
    );
  }
}