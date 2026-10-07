import 'package:flutter/material.dart';
import '../services/carrito_service.dart';
import 'checkout_page.dart';

class CarritoPage extends StatefulWidget {
  final CarritoService carrito;
  const CarritoPage({super.key, required this.carrito});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  @override
  void initState() {
    super.initState();
    widget.carrito.addListener(() => setState(() {}));
  }

  void _confirmar() {
    if (widget.carrito.vacio) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(carrito: widget.carrito),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.carrito.items;
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: items.isEmpty
          ? const Center(child: Text('Tu carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return ListTile(
                        title: Text(item.resumen),
                        subtitle: Text('Cantidad: ${item.cantidad}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${item.subtotal.toStringAsFixed(2)}'),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  widget.carrito.quitar(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total: \$${widget.carrito.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _confirmar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Ordenar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}