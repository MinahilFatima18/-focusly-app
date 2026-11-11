import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const FocuslyApp());

class FocuslyApp extends StatelessWidget {
  const FocuslyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'focusly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
      ),
      home: const SplashScreen(),
    );
  }
}
