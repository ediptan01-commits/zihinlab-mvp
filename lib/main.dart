import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
void main() => runApp(const ZihinLabApp());
class ZihinLabApp extends StatelessWidget {
  const ZihinLabApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'ZihinLab', debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF080D20), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF38D9FF), brightness: Brightness.dark, surface: const Color(0xFF111A32)), useMaterial3: true),
    home: const GameScreen());
}
