import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'timer_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps the timer running when you switch tabs
      body: SafeArea(
        child: IndexedStack(index: _tab, children: const [TimerScreen(), StatsScreen(), SettingsScreen()]),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: kSurface,
        indicatorColor: const Color(0xFFFFD9D5),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'Timer'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
