import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../state/app_state.dart';
import '../utils/helpers.dart';
import 'history_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _week = true;

  Widget _tile(IconData ic, String big, String small, Color bg) {
    return Expanded(
      child: Container(
        height: 120,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(28)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(ic, color: kTextDark),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(big, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: kTextDark)),
              Text(small, style: const TextStyle(fontSize: 14, color: kTextDark)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _chip(String t, bool sel, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: sel ? const Color(0xFFFFD9D5) : Colors.transparent,
            border: Border.all(color: sel ? Colors.transparent : const Color(0xFFD9C2BE)),
            borderRadius: BorderRadius.circular(10)),
        child: Text(t, style: const TextStyle(color: kTextDark)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final today = DateTime.now();
        final day0 = DateTime(today.year, today.month, today.day);

        // streak = consecutive days (ending today/yesterday) with focus
        int streak = 0;
        for (int i = 0; i < 365; i++) {
          if (focusOn(day0.subtract(Duration(days: i))) > 0) {
            streak++;
          } else if (i > 0) {
            break;
          } else {
            continue;
          }
        }
        final sessionsToday =
            app.history.where((e) => e.type == 'Focus' && sameDay(e.time, today)).length;
        final last7 = List.generate(7, (i) => focusOn(day0.subtract(Duration(days: 6 - i))));
        final total7 = last7.fold(0, (a, b) => a + b);

        // bars: week = 7 days, month = 4 weeks
        late List<int> vals;
        late List<String> labels;
        if (_week) {
          vals = last7;
          labels = List.generate(
              7, (i) => ['M', 'T', 'W', 'T', 'F', 'S', 'S'][day0.subtract(Duration(days: 6 - i)).weekday - 1]);
        } else {
          vals = List.generate(4, (w) {
            int s = 0;
            for (int d = 0; d < 7; d++) {
              s += focusOn(day0.subtract(Duration(days: (3 - w) * 7 + 6 - d)));
            }
            return s;
          });
          labels = ['W1', 'W2', 'W3', 'W4'];
        }
        final maxV = math.max(1, vals.reduce(math.max));

        // focus by task
        final byTask = <String, int>{};
        for (final e in app.history.where((e) => e.type == 'Focus')) {
          byTask[e.title] = (byTask[e.title] ?? 0) + e.min;
        }
        final tasks = byTask.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            topBar('Statistics', menu: const [
              PopupMenuItem(value: 'h', child: Text('Session history')),
              PopupMenuItem(value: 'r', child: Text('Reset statistics')),
            ], onMenu: (v) {
              if (v == 'r') {
                confirmReset(context);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
              }
            }),
            Row(children: [
              _tile(Icons.timer_outlined, fmtDur(focusOn(today)), 'Focus today', const Color(0xFFFFD9D5)),
              _tile(Icons.local_fire_department, '$streak days', 'Current streak', const Color(0xFFFCDFB5)),
            ]),
            Row(children: [
              _tile(Icons.check, '$sessionsToday', 'Sessions today', const Color(0xFF9CF2E3)),
              _tile(Icons.bar_chart, fmtDur(total7 ~/ 7), 'Daily average', const Color(0xFFF5E1DE)),
            ]),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(28)),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_week ? 'Last 7 days' : 'Last 4 weeks',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                      Text('${fmtDur(vals.fold(0, (a, b) => a + b))} total',
                          style: const TextStyle(color: kTextGrey)),
                    ]),
                    Row(children: [
                      _chip('Week', _week, () => setState(() => _week = true)),
                      _chip('Month', !_week, () => setState(() => _week = false)),
                    ]),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 170,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(vals.length, (i) {
                      final last = i == vals.length - 1;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (last)
                            Text('${(vals[i] / 60).toStringAsFixed(1)}h',
                                style: const TextStyle(
                                    color: kPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Container(
                            width: _week ? 28 : 50,
                            height: 4 + 110 * vals[i] / maxV,
                            decoration: BoxDecoration(
                                color: last ? kPrimary : const Color(0xFFFFD9D5),
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          const SizedBox(height: 6),
                          Text(labels[i],
                              style: TextStyle(
                                  color: last ? kPrimary : kTextGrey,
                                  fontWeight: last ? FontWeight.w700 : FontWeight.w400)),
                        ],
                      );
                    }),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 20, 0, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Focus by task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  TextButton(
                    onPressed: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                    child: const Text('See all', style: TextStyle(color: kPrimary)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(28)),
              child: Column(
                children: [
                  if (tasks.isEmpty) const Text('No data yet'),
                  for (final t in tasks.take(5))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(t.key, style: const TextStyle(fontSize: 16)),
                            Text(fmtDur(t.value), style: const TextStyle(color: kTextGrey)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                              value: t.value / tasks.first.value,
                              minHeight: 8,
                              color: kPrimary,
                              backgroundColor: const Color(0xFFEBD9D6)),
                        ),
                      ]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
