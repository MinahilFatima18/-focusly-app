import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/ring_painter.dart';
import 'main_screen.dart';

class OnboardingData {
  final String title, text;
  final IconData icon;
  final Color boxColor, ringColor, ringTrackColor, iconColor;
  OnboardingData(this.title, this.text, this.icon, this.boxColor, this.ringColor, this.ringTrackColor,
      this.iconColor);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
        'Focus in boxes of time',
        'Work in short, focused 25-minute sessions. One box at a time — no multitasking.',
        Icons.timer_outlined,
        const Color(0xFFFFD9D5),
        kPrimary,
        const Color(0xFFEBA9A6),
        const Color(0xFF3F0004)),
    OnboardingData(
        'Rest, then go again',
        'Short breaks keep your mind fresh, and a long break after every 4 sessions.',
        Icons.coffee_outlined,
        const Color(0xFFCDF5EE),
        kTertiary,
        const Color(0xFF8FD3C8),
        const Color(0xFF00201C)),
    OnboardingData(
        'See your progress',
        'Track focus time, build streaks and see where your hours go each week.',
        Icons.bar_chart,
        const Color(0xFFFCDFB5),
        kPrimary,
        const Color(0xFFECA98A),
        const Color(0xFF251A00)),
  ];

  void _goToApp() =>
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));

  void _onNextPressed() {
    if (_currentPage == _pages.length - 1) {
      _goToApp();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: TextButton(
                  onPressed: _goToApp,
                  child: const Text('Skip',
                      style: TextStyle(color: kPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => OnboardingPage(data: _pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: active ? kPrimary : const Color(0xFFD9D0CE),
                      borderRadius: BorderRadius.circular(10)),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: _onNextPressed,
                  style: FilledButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
                  child: Text(isLast ? 'Get started' : 'Next',
                      style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(color: data.boxColor, borderRadius: BorderRadius.circular(60)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 165,
                  height: 165,
                  child: CustomPaint(
                      painter: RingPainter(
                          progress: 0.85,
                          color: data.ringColor,
                          trackColor: data.ringTrackColor,
                          strokeWidth: 9)),
                ),
                Icon(data.icon, size: 64, color: data.iconColor),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Text(data.title,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, color: kTextDark)),
          const SizedBox(height: 16),
          Text(data.text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: kTextGrey, height: 1.4)),
        ],
      ),
    );
  }
}
