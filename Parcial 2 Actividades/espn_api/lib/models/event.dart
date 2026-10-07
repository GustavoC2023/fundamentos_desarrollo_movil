class Event {
  final String id;
  final String name;
  final DateTime date;
  final String shortName;
  final int week;
  final String statusDetail;
  final String homeTeam;
  final String awayTeam;
  final String? homeLogo;
  final String? awayLogo;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.shortName,
    required this.week,
    required this.statusDetail,
    required this.homeTeam,
    required this.awayTeam,
    this.homeLogo,
    this.awayLogo,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final competition = json['competitions'][0];
    final competitors = competition['competitors'] as List;

    final home = competitors.firstWhere((c) => c['homeAway'] == 'home');
    final away = competitors.firstWhere((c) => c['homeAway'] == 'away');

    return Event(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']).toLocal(),
      shortName: json['shortName'],
      week: json['week']['number'],
      statusDetail: json['status']['type']['detail'],
      homeTeam: home['team']['displayName'],
      awayTeam: away['team']['displayName'],
      homeLogo: home['team']['logo'],
      awayLogo: away['team']['logo'],
    );
  }
}