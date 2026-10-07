import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/api_service.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final ApiService _api = ApiService();
  late Future<List<Event>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchUpcomingEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Próximos partidos NFL')),
      body: FutureBuilder<List<Event>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return const Center(child: Text('No hay partidos próximos'));
          }
          return _buildGroupedList(events);
        },
      ),
    );
  }

  Widget _buildGroupedList(List<Event> events) {
    final dateFormat = DateFormat('EEEE d MMM y', 'en');
    final timeFormat = DateFormat('h:mm a');

    // Agrupar por fecha (solo día)
    final Map<String, List<Event>> grouped = {};
    for (final e in events) {
      final key = dateFormat.format(e.date);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    final sections = grouped.entries.toList();

    return ListView.builder(
      itemCount: sections.length,
      itemBuilder: (context, i) {
        final section = sections[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                section.key.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            ...section.value.map((e) => _buildEventTile(e, timeFormat)),
          ],
        );
      },
    );
  }

  Widget _buildEventTile(Event event, DateFormat timeFormat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event.awayLogo != null)
              Image.network(event.awayLogo!, width: 28, height: 28),
            const SizedBox(width: 4),
            if (event.homeLogo != null)
              Image.network(event.homeLogo!, width: 28, height: 28),
          ],
        ),
        title: Text('${event.awayTeam} @ ${event.homeTeam}',
            style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          'Semana ${event.week} · ${timeFormat.format(event.date)}\n${event.statusDetail}',
        ),
        isThreeLine: true,
      ),
    );
  }
}