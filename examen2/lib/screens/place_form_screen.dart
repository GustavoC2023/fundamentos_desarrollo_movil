import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/place.dart';
import '../services/place_service.dart';

class PlaceFormScreen extends StatefulWidget {
  final Place? place;
  const PlaceFormScreen({super.key, this.place});

  @override
  State<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _service = PlaceService();
  final _picker = ImagePicker();

  String _category = 'comida';
  LatLng? _selectedPoint;
  File? _pickedImage;
  String? _existingPhotoUrl;
  bool _isSaving = false;

  final List<String> _categories = ['comida', 'estudio', 'diversion'];

  // Centro por defecto: CDMX (puedes cambiarlo a tu ciudad)
  final LatLng _defaultCenter = const LatLng(19.4326, -99.1332);

  @override
  void initState() {
    super.initState();
    if (widget.place != null) {
      _nameController.text = widget.place!.name;
      _category = widget.place!.category;
      _selectedPoint = LatLng(widget.place!.latitude, widget.place!.longitude);
      _existingPhotoUrl = widget.place!.photoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _pickedImage = File(image.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toca el mapa para elegir la ubicación')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // 1. Subir foto si hay una nueva
      String? photoUrl = _existingPhotoUrl;
      if (_pickedImage != null) {
        photoUrl = await _service.uploadPhoto(_pickedImage!);
      }

      if (widget.place == null) {
        // CREAR
        final newPlace = Place(
          id: '',
          userId: userId,
          name: _nameController.text.trim(),
          category: _category,
          latitude: _selectedPoint!.latitude,
          longitude: _selectedPoint!.longitude,
          photoUrl: photoUrl,
          createdAt: DateTime.now(),
        );
        await _service.createPlace(newPlace);
      } else {
        // ACTUALIZAR
        await _service.updatePlace(widget.place!.id, {
          'name': _nameController.text.trim(),
          'category': _category,
          'latitude': _selectedPoint!.latitude,
          'longitude': _selectedPoint!.longitude,
          'photo_url': photoUrl,
        });
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place == null ? 'Agregar lugar' : 'Editar lugar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del lugar',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Escribe un nombre' : null,
              ),
              const SizedBox(height: 16),

              // Categoría
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),

              // Foto
              Text(
                'Foto',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (_pickedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_pickedImage!,
                      height: 180, fit: BoxFit.cover),
                )
              else if (_existingPhotoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(_existingPhotoUrl!,
                      height: 180, fit: BoxFit.cover),
                )
              else
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('Sin foto')),
                ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Elegir foto'),
              ),
              const SizedBox(height: 20),

              // Mapa para elegir coordenadas
              Text(
                'Ubicación (toca el mapa)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 260,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _selectedPoint ?? _defaultCenter,
                      initialZoom: 14,
                      onTap: (tapPosition, point) {
                        setState(() => _selectedPoint = point);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.examen2',
                      ),
                      if (_selectedPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPoint!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              if (_selectedPoint != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Lat: ${_selectedPoint!.latitude.toStringAsFixed(5)}, '
                    'Lng: ${_selectedPoint!.longitude.toStringAsFixed(5)}',
                  ),
                ),
              const SizedBox(height: 24),

              // Botón guardar
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.place == null ? 'Guardar' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}