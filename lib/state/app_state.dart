import 'package:flutter/material.dart';
import '../models/entry.dart';

class AppState extends ChangeNotifier {
  // settings
  int focus = 25, shortB = 5, longB = 15, longAfter = 4;
  bool autoBreak = true, autoFocus = false, keepOn = true, notif = true;
  String alarm = 'Bell';
  String task = 'Learning Flutter Basics';
  late List<Entry> history = _seed();

  void changed() => notifyListeners();

  void log(String title, String type, int min) {
    history.insert(0, Entry(title, type, min, DateTime.now()));
    notifyListeners();
  }

  void resetStats() {
    history.clear();
    notifyListeners();
  }

  // sample data so Stats/History look full on first run
  List<Entry> _seed() {
    final n = DateTime.now();
    DateTime at(int d, int h, int m) => DateTime(n.year, n.month, n.day - d, h, m);
    final l = <Entry>[
      Entry('Learning Flutter Basics', 'Focus', 25, at(0, 9, 33)),
      Entry('Short break', 'Short break', 5, at(0, 9, 58)),
      Entry('Learning Flutter Basics', 'Focus', 25, at(0, 10, 5)),
      Entry('Write API docs', 'Skipped', 12, at(0, 9, 10)),
      Entry('Code review', 'Focus', 25, at(1, 15, 30)),
      Entry('Long break', 'Long break', 15, at(1, 15, 55)),
      Entry('Code review', 'Focus', 25, at(1, 16, 20)),
    ];
    for (int d = 2; d <= 28; d++) {
      final k = 2 + d % 4; // 2..5 sessions a day
      for (int i = 0; i < k; i++) {
        l.add(Entry(d % 2 == 0 ? 'Write API docs' : 'Reading', 'Focus', 25, at(d, 10 + i, 0)));
      }
    }
    l.sort((a, b) => b.time.compareTo(a.time));
    return l;
  }
}

final AppState app = AppState();
