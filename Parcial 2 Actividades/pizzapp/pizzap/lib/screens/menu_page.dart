import 'package:flutter/material.dart';
import '../data/pizzas_repository.dart';
import '../models/pizza.dart';
import '../services/auth_service.dart';
import '../services/carrito_service.dart';
import '../widgets/pizza_card.dart';
import 'carrito_page.dart';
import 'personalizar_pizza_page.dart';
import 'mapa_page.dart';
import 'perfil_page.dart';

class MenuPage extends StatefulWidget {
  final AuthService authService;
  const MenuPage({super.key, required this.authService});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final _repo = PizzasRepositoryLocal();
  final _carrito = CarritoService();

  List<Pizza> _pizzas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
    _carrito.addListener(() => setState(() {}));
  }

  Future<void> _cargar() async {
    final p = await _repo.obtenerPizzas();
    setState(() {
      _pizzas = p;
      _cargando = false;
    });
  }

  void _abrirCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarritoPage(carrito: _carrito),
      ),
    );
  }

  void _abrirMapa() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapaPage()),
    );
  }

  void _abrirPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PerfilPage(authService: widget.authService), // ← cambio
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Mi perfil',
            onPressed: _abrirPerfil,
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: _abrirMapa,
            tooltip: 'Ver sucursal',
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: _abrirCarrito,
              ),
              if (_carrito.cantidadTotal > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_carrito.cantidadTotal}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Pizzas predeterminadas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._pizzas.map(
                  (p) => PizzaCard(
                    pizza: p,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PersonalizarPizzaPage(
                          pizza: p,
                          carrito: _carrito,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.build_outlined),
                    label: const Text('Crear pizza personalizada'),
                    onPressed: () async {
                      final ingredientes = await _repo.obtenerIngredientes();
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PersonalizarPizzaPage(
                            pizza: Pizza(
                              nombre: 'Personalizada',
                              descripcion: 'Arma tu pizza',
                              precioMediana: 119,
                              precioGrande: 149,
                              ingredientes: [],
                              esPersonalizada: true,
                            ),
                            carrito: _carrito,
                            ingredientesDisponibles: ingredientes,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}