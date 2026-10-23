import 'package:flutter/material.dart';

import 'screens/game_screen.dart';

void main() => runApp(const ZihinLabApp());

class ZihinLabApp extends StatelessWidget {
  const ZihinLabApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ZihinLab',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF080D20),
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF38D9FF),
            brightness: Brightness.dark,
            surface: const Color(0xFF111A32),
          ).copyWith(
            primary: const Color(0xFF38D9FF),
            secondary: const Color(0xFF9B6BFF),
            surface: const Color(0xFF111A32),
          ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF18233C),
        contentTextStyle: const TextStyle(color: Color(0xFFE8EEFB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    ),
    home: const GameScreen(),
  );
}
