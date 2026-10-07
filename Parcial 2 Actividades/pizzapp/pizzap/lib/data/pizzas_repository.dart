import '../models/ingrediente.dart';
import '../models/pizza.dart';

abstract class PizzasRepository {
  Future<List<Pizza>> obtenerPizzas();
  Future<List<Ingrediente>> obtenerIngredientes();
}

class PizzasRepositoryLocal implements PizzasRepository {
  @override
  Future<List<Pizza>> obtenerPizzas() async {
    return [
      Pizza(
        id: 1,
        nombre: 'Hawaiana',
        descripcion: 'Piña, jamón y queso',
        precioMediana: 119,
        precioGrande: 159,
        ingredientes: ['piña', 'jamón', 'queso'],
        emoji: '🍍',
      ),
      Pizza(
        id: 2,
        nombre: 'Pepperoni',
        descripcion: 'Pepperoni y queso',
        precioMediana: 109,
        precioGrande: 139,
        ingredientes: ['pepperoni', 'queso'],
        emoji: '🍕',
      ),
      Pizza(
        id: 3,
        nombre: 'Queso',
        descripcion: 'Extra queso',
        precioMediana: 99,
        precioGrande: 129,
        ingredientes: ['queso'],
        emoji: '🧀',
      ),
      Pizza(
        id: 4,
        nombre: 'Carnívora',
        descripcion: 'Pepperoni, carne y jamón',
        precioMediana: 139,
        precioGrande: 179,
        ingredientes: ['pepperoni', 'carne', 'jamón'],
        emoji: '🥩',
      ),
    ];
  }

  @override
  Future<List<Ingrediente>> obtenerIngredientes() async {
    return [
      Ingrediente(id: 1, nombre: 'Pepperoni'),
      Ingrediente(id: 2, nombre: 'Champiñones'),
      Ingrediente(id: 3, nombre: 'Carne'),
      Ingrediente(id: 4, nombre: 'Salchicha'),
      Ingrediente(id: 5, nombre: 'Pimiento'),
    ];
  }
}