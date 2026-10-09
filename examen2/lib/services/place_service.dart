import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/place.dart';

class PlaceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtener todos los lugares del usuario actual
  Future<List<Place>> getMyPlaces() async {
    final data = await _supabase
        .from('places')
        .select()
        .order('created_at', ascending: false);

    return (data as List)
        .map((item) => Place.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Subir una foto al bucket y devolver su URL pública
  Future<String> uploadPhoto(File file) async {
    final userId = _supabase.auth.currentUser!.id;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$fileName';

    await _supabase.storage.from('place-photos').upload(path, file);

    return _supabase.storage.from('place-photos').getPublicUrl(path);
  }

  /// Crear un lugar
  Future<void> createPlace(Place place) async {
    await _supabase.from('places').insert(place.toMap());
  }

  /// Actualizar un lugar
  Future<void> updatePlace(String id, Map<String, dynamic> data) async {
    await _supabase.from('places').update(data).eq('id', id);
  }

  /// Eliminar un lugar
  Future<void> deletePlace(String id) async {
    await _supabase.from('places').delete().eq('id', id);
  }
}