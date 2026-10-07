import 'package:flutter/material.dart';
import 'package:mhj_maps/mhj_maps.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/carrito_service.dart';

class CheckoutPage extends StatefulWidget {
  final CarritoService carrito;
  const CheckoutPage({super.key, required this.carrito});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // 🏪 Sucursal: Agustín de Iturbide 430A, Centro Histórico, SLP
  static const _sucursal = MhjMapsLatLng(lat: 22.1497, lng: -100.9754);
  static const _fallback = MhjMapsLatLng(lat: 22.1497, lng: -100.9754);

  final _nav = MhjMaps();
  final _detallesController = TextEditingController();
  MhjMapsMapController? _controller;
  dynamic _ruta;
  bool _calculando = true;
  String? _estado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _iniciar());
  }

  @override
  void dispose() {
    _detallesController.dispose();
    super.dispose();
  }

  Future<void> _iniciar() async {
    final origen = await _obtenerUbicacion();
    await _calcularRuta(origen);
  }

  Future<MhjMapsLatLng> _obtenerUbicacion() async {
    setState(() => _estado = 'Solicitando permiso de ubicación...');
    final permiso = await Permission.location.request();

    if (!permiso.isGranted) {
      setState(() => _estado =
          '⚠️ Permiso denegado. Usando ubicación de referencia.');
      return _fallback;
    }

    try {
      setState(() => _estado = '📍 Obteniendo tu ubicación...');
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      setState(() => _estado =
          '✅ Ubicación real: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
      return MhjMapsLatLng(lat: pos.latitude, lng: pos.longitude);
    } catch (e) {
      setState(() => _estado =
          '⚠️ No se pudo obtener GPS. Usando ubicación de referencia.');
      return _fallback;
    }
  }

  Future<void> _calcularRuta(MhjMapsLatLng origen) async {
    try {
      final ruta = await _nav.route(
        origin: origen,
        destination: _sucursal,
        costing: 'auto',
      );
      _controller?.drawRoute(
        ruta.polyline,
        color: Colors.blue,
        width: 5.0,
        borderColor: Colors.black26,
        borderWidth: 1,
      );
      _controller?.fitRoute(ruta.polyline);
      setState(() => _ruta = ruta);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al calcular ruta: $e')),
      );
    } finally {
      setState(() => _calculando = false);
    }
  }

  void _confirmarPedido() {
    if (_detallesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe los detalles de tu dirección')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¡Pedido confirmado!'),
        content: Text(
          'Tu pedido llegará a:\n${_detallesController.text}\n\n'
          'Total: \$${widget.carrito.total.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // cierra diálogo
              Navigator.pop(context); // cierra checkout
              widget.carrito.limpiar();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar pedido'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black87,
      ),
      body: _calculando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Mapa (arriba)
                Expanded(
                  flex: 3,
                  child: MhjMapsMap(
                    center: _sucursal,
                    zoom: 14,
                    tileProvider: MhjMapsTileProvider.custom(
                      urlTemplate:
                          'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=cb1_49x8_1_931f3177d8e05a92b69089ee',
                      name: 'Carto Voyager',
                      attribution: '© OpenStreetMap contributors, © CARTO',
                    ),
                    showZoomControls: true,
                    onMapCreated: (controller) {
                      _controller = controller;
                      controller.addCustomMarker(
                        position: _sucursal,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.black54, width: 1.5),
                          ),
                          child: const Text('🍕',
                              style: TextStyle(fontSize: 20)),
                        ),
                      );
                      // Si ya hay ruta calculada, redibujarla
                      if (_ruta != null) {
                        controller.drawRoute(_ruta.polyline,
                            color: Colors.blue, width: 5.0);
                        controller.fitRoute(_ruta.polyline);
                      }
                    },
                  ),
                ),

                // Info (abajo)
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_estado != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _estado!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        if (_ruta != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                Text('⏱ ${_ruta!.durationText}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text('📍 ${_ruta!.distanceText}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        TextField(
                          controller: _detallesController,
                          decoration: const InputDecoration(
                            labelText: 'Detalles de dirección',
                            hintText: 'Número, colonia, referencias...',
                            prefixIcon: Icon(Icons.home_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total: \$${widget.carrito.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Confirmar pedido'),
                          onPressed: _confirmarPedido,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}