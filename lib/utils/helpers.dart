import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../state/app_state.dart';

String fmtDur(int m) => m >= 60 ? '${m ~/ 60}h ${m % 60}m' : '${m}m';

String fmtTime(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'AM' : 'PM'}';
}

String dayLabel(DateTime d) {
  const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final n = DateTime.now();
  final diff = DateTime(n.year, n.month, n.day).difference(DateTime(d.year, d.month, d.day)).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return '${wd[d.weekday - 1]}, ${d.day} ${mo[d.month - 1]}';
}

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

int focusOn(DateTime day) => app.history
    .where((e) => e.type == 'Focus' && sameDay(e.time, day))
    .fold(0, (s, e) => s + e.min);

Widget topBar(String title, {List<PopupMenuEntry<String>>? menu, void Function(String)? onMenu}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 26, color: kTextDark)),
        if (menu != null)
          PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: kTextDark),
              onSelected: onMenu,
              itemBuilder: (_) => menu)
        else
          const Icon(Icons.more_vert, color: kTextDark),
      ],
    ),
  );
}

// "Reset statistics?" dialog
void confirmReset(BuildContext context) {
  showDialog(
    context: context,
    builder: (d) => AlertDialog(
      backgroundColor: const Color(0xFFF5E4E1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      icon: const Icon(Icons.delete, color: kPrimary),
      title: const Text('Reset statistics?'),
      content: const Text(
          "This permanently deletes all session history, streaks and stats. This can't be undone.",
          textAlign: TextAlign.center),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Cancel', style: TextStyle(color: kPrimary))),
        TextButton(
            onPressed: () {
              app.resetStats();
              Navigator.pop(d);
            },
            child: const Text('Reset', style: TextStyle(color: kPrimary))),
      ],
    ),
  );
}
