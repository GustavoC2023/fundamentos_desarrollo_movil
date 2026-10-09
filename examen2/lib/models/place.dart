class Place {
  final String id;
  final String userId;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final DateTime createdAt;

  Place({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    required this.createdAt,
  });

  /// Crear un Place desde un Map (lo que devuelve Supabase)
  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      photoUrl: map['photo_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convertir a Map (para insertar/actualizar en Supabase)
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'photo_url': photoUrl,
    };
  }
}