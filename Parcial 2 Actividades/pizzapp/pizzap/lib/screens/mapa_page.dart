import 'package:flutter/material.dart';
import 'package:mhj_maps/mhj_maps.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  // 🏪 Sucursal: Agustín de Iturbide 430A, Centro Histórico, SLP
  static const _sucursal = MhjMapsLatLng(lat: 22.1497, lng: -100.9754);

  // Fallback si no hay GPS (Centro SLP)
  static const _fallback = MhjMapsLatLng(lat: 22.1497, lng: -100.9754);

  final _nav = MhjMaps();
  MhjMapsMapController? _controller;
  dynamic _ruta;
  bool _calculando = false;
  String? _estadoUbicacion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sucursal')),
      body: Column(
        children: [
          Expanded(
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
                // Marcador de la sucursal 🍕
                controller.addCustomMarker(
                  position: _sucursal,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black54, width: 1.5),
                    ),
                    child: const Text('🍕', style: TextStyle(fontSize: 20)),
                  ),
                );
              },
            ),
          ),
          if (_estadoUbicacion != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                _estadoUbicacion!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (_ruta != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('⏱ ${_ruta!.durationText}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('📍 ${_ruta!.distanceText}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.directions),
              label: Text(_calculando ? 'Calculando...' : 'Cómo llegar'),
              onPressed: _calculando ? null : _calcularRuta,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black87,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pide permiso de ubicación y devuelve la posición real (o fallback).
  Future<MhjMapsLatLng> _obtenerUbicacion() async {
    setState(() => _estadoUbicacion = 'Solicitando permiso de ubicación...');

    final permiso = await Permission.location.request();

    if (!permiso.isGranted) {
      setState(() => _estadoUbicacion =
          '⚠️ Permiso denegado. Usando ubicación de referencia (Centro SLP).');
      return _fallback;
    }

    try {
      setState(() => _estadoUbicacion = '📍 Obteniendo tu ubicación...');
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      setState(() => _estadoUbicacion =
          '✅ Ubicación real: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
      return MhjMapsLatLng(lat: pos.latitude, lng: pos.longitude);
    } catch (e) {
      setState(() => _estadoUbicacion =
          '⚠️ No se pudo obtener GPS. Usando ubicación de referencia.');
      return _fallback;
    }
  }

  Future<void> _calcularRuta() async {
    setState(() => _calculando = true);
    try {
      final origen = await _obtenerUbicacion();

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
}