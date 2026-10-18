import 'package:flutter/material.dart';
import 'game/sound_service.dart';
import 'ui/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundService().init();
  runApp(const SortBaazApp());
}

class SortBaazApp extends StatelessWidget {
  const SortBaazApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SortBaaz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
