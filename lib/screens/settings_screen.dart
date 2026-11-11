import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../state/app_state.dart';
import '../utils/helpers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _section(String t, List<Widget> rows) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 0, 8),
        child: Text(t, style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w600)),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(28)),
        child: Column(children: rows),
      ),
    ]);
  }

  Widget _stepper(IconData ic, String t, String sub, int v, int min, int max, void Function(int) on) {
    Widget btn(IconData i, VoidCallback f) => GestureDetector(
          onTap: f,
          child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
              child: Icon(i, size: 20)),
        );
    return ListTile(
      leading: Icon(ic, color: kTextGrey),
      title: Text(t, style: const TextStyle(fontSize: 17)),
      subtitle: Text(sub),
      trailing: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: const Color(0xFFF5E1DE), borderRadius: BorderRadius.circular(30)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          btn(Icons.remove, () {
            if (v > min) {
              on(v - 1);
              app.changed();
            }
          }),
          SizedBox(width: 36, child: Center(child: Text('$v', style: const TextStyle(fontSize: 16)))),
          btn(Icons.add, () {
            if (v < max) {
              on(v + 1);
              app.changed();
            }
          }),
        ]),
      ),
    );
  }

  Widget _switch(IconData ic, String t, String sub, bool v, void Function(bool) on) {
    return ListTile(
      leading: Icon(ic, color: kTextGrey),
      title: Text(t, style: const TextStyle(fontSize: 17)),
      subtitle: Text(sub),
      trailing: Switch(
        value: v,
        activeColor: Colors.white,
        activeTrackColor: kPrimary,
        onChanged: (x) {
          on(x);
          app.changed();
        },
      ),
    );
  }

  void _alarmDialog(BuildContext context) {
    String sel = app.alarm;
    showDialog(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: const Color(0xFFF5E4E1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Alarm sound'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Bell', 'Chime', 'Digital', 'Birds', 'Silent']
                .map((s) => RadioListTile<String>(
                      value: s,
                      groupValue: sel,
                      activeColor: kPrimary,
                      title: Text(s),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setD(() => sel = v!),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(d),
                child: const Text('Cancel', style: TextStyle(color: kPrimary))),
            TextButton(
                onPressed: () {
                  app.alarm = sel;
                  app.changed();
                  Navigator.pop(d);
                },
                child: const Text('OK', style: TextStyle(color: kPrimary))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          topBar('Settings',
              menu: const [PopupMenuItem(value: 'r', child: Text('Reset statistics'))],
              onMenu: (_) => confirmReset(context)),
          _section('Timer', [
            _stepper(Icons.timer_outlined, 'Focus', 'Minutes per session', app.focus, 1, 90, (v) => app.focus = v),
            _stepper(Icons.coffee, 'Short break', 'Minutes', app.shortB, 1, 30, (v) => app.shortB = v),
            _stepper(Icons.coffee, 'Long break', 'Minutes', app.longB, 1, 60, (v) => app.longB = v),
            _stepper(Icons.history, 'Long break after', 'Focus sessions', app.longAfter, 2, 8, (v) => app.longAfter = v),
          ]),
          _section('Behaviour', [
            _switch(Icons.bolt, 'Auto-start breaks', 'Start a break when focus ends', app.autoBreak,
                (v) => app.autoBreak = v),
            _switch(Icons.bolt, 'Auto-start focus', 'Start focus when a break ends', app.autoFocus,
                (v) => app.autoFocus = v),
            _switch(Icons.light_mode, 'Keep screen on', 'While the timer is running', app.keepOn,
                (v) => app.keepOn = v),
          ]),
          _section('Sound & notifications', [
            _switch(Icons.notifications, 'Notifications', 'Alert when a session ends', app.notif,
                (v) => app.notif = v),
            ListTile(
              leading: const Icon(Icons.music_note, color: kTextGrey),
              title: const Text('Alarm sound', style: TextStyle(fontSize: 17)),
              subtitle: Text(app.alarm),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _alarmDialog(context),
            ),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
