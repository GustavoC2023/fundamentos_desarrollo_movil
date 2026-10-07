import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class ApiService {
  static const String _url =
      'https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard';

  Future<List<Event>> fetchUpcomingEvents() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode != 200) {
      throw Exception('Error al cargar los eventos');
    }

    final data = jsonDecode(response.body);
    final eventsJson = data['events'] as List;

    final now = DateTime.now();

    final events = eventsJson
        .map((e) => Event.fromJson(e))
        .where((e) => e.date.isAfter(now))
        .toList();

    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }
}