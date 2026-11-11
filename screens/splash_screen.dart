import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/ring_painter.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(32)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CustomPaint(
                        painter: RingPainter(
                            progress: 0.75,
                            color: Colors.white,
                            trackColor: const Color(0xFFD35B59),
                            strokeWidth: 8)),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('focusly', style: TextStyle(fontSize: 34, color: kTextDark)),
          ],
        ),
      ),
    );
  }
}
