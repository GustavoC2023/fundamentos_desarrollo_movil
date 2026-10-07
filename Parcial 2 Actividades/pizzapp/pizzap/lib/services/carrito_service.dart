import 'package:flutter/foundation.dart';
import '../models/item_pedido.dart';

class CarritoService extends ChangeNotifier {
  final List<ItemPedido> _items = [];

  List<ItemPedido> get items => List.unmodifiable(_items);
  int get cantidadTotal => _items.fold(0, (s, i) => s + i.cantidad);
  double get total => _items.fold(0, (s, i) => s + i.subtotal);
  bool get vacio => _items.isEmpty;

  void agregar(ItemPedido item) {
    _items.add(item);
    notifyListeners();
  }

  void quitar(ItemPedido item) {
    _items.remove(item);
    notifyListeners();
  }

  void limpiar() {
    _items.clear();
    notifyListeners();
  }
}