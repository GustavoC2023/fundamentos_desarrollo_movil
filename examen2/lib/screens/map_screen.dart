import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/place.dart';
import '../services/place_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _service = PlaceService();

  List<Place> _places = [];
  LatLng? _myLocation;
  bool _isLoading = true;
  Place? _selectedPlace;

  // Centro por defecto: CDMX
  final LatLng _defaultCenter = const LatLng(19.4326, -99.1332);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadPlaces();
    await _getMyLocation();
    setState(() => _isLoading = false);
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await _service.getMyPlaces();
      setState(() => _places = places);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando lugares: $e')),
        );
      }
    }
  }

  Future<void> _getMyLocation() async {
    try {
      // Verificar si el servicio de ubicación está activo
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Activa la ubicación en tu dispositivo');
        return;
      }

      // Verificar permiso
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack('Permiso de ubicación denegado');
        return;
      }

      // Obtener posición
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _myLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      _showSnack('No se pudo obtener tu ubicación: $e');
    }
  }

  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _goToMyLocation() {
    if (_myLocation == null) {
      _showSnack('Ubicación no disponible');
      return;
    }
    // Forzar reconstrucción para centrar — usamos un MapController
    _mapController.move(_myLocation!, 15);
  }

  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mapa')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de lugares')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _myLocation ?? _defaultCenter,
              initialZoom: 13,
              onTap: (_, __) => setState(() => _selectedPlace = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.examen2',
              ),

              // Marcadores de lugares
              MarkerLayer(
                markers: _places.map((place) {
                  final isSelected = _selectedPlace?.id == place.id;
                  return Marker(
                    point: LatLng(place.latitude, place.longitude),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPlace = place),
                      child: Icon(
                        Icons.location_on,
                        color: isSelected ? Colors.red : Colors.deepPurple,
                        size: isSelected ? 50 : 40,
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Mi ubicación (pin azul)
              if (_myLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _myLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Botón flotante "ir a mi ubicación"
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'myLocation',
              onPressed: _goToMyLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          // Info del lugar seleccionado (bottom sheet tipo tarjeta)
          if (_selectedPlace != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      if (_selectedPlace!.photoUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _selectedPlace!.photoUrl!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported, size: 40),
                          ),
                        )
                      else
                        const Icon(Icons.place, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedPlace!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Categoría: ${_selectedPlace!.category}'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            setState(() => _selectedPlace = null),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}