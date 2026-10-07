import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'ui/events_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFL Próximos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const EventsPage(),
    );
  }
}