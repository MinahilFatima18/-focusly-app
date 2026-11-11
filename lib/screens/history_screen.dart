import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/entry.dart';
import '../state/app_state.dart';
import '../utils/helpers.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'All';

  bool _show(Entry e) {
    if (_filter == 'All') return true;
    if (_filter == 'Focus') return e.type == 'Focus' || e.type == 'Skipped';
    return e.type.endsWith('break');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackground,
        title: const Text('Session history', style: TextStyle(fontSize: 24)),
      ),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          // group entries by day (history is already newest first)
          final groups = <String, List<Entry>>{};
          for (final e in app.history.where(_show)) {
            groups.putIfAbsent('${e.time.year}-${e.time.month}-${e.time.day}', () => []).add(e);
          }
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Row(
                children: ['All', 'Focus', 'Breaks']
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: _filter == f,
                            selectedColor: const Color(0xFFFFD9D5),
                            onSelected: (_) => setState(() => _filter = f),
                          ),
                        ))
                    .toList(),
              ),
              if (groups.isEmpty)
                const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No sessions yet'))),
              for (final list in groups.values) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 0, 8),
                  child: Text(
                    '${dayLabel(list.first.time)} · ${fmtDur(list.where((e) => e.type == 'Focus').fold(0, (s, e) => s + e.min))}',
                    style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(28)),
                  child: Column(children: list.map(_row).toList()),
                ),
              ],
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _row(Entry e) {
    final isBreak = e.type.endsWith('break');
    final skipped = e.type == 'Skipped';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isBreak
            ? kTertiaryLight
            : skipped
                ? const Color(0xFFEBD9D6)
                : const Color(0xFFFFD9D5),
        child: Icon(isBreak ? Icons.coffee : skipped ? Icons.remove_circle : Icons.check,
            color: skipped ? kTextGrey : kTextDark),
      ),
      title: Text(e.title),
      subtitle: Text('${isBreak ? 'Break' : e.type} · ${fmtTime(e.time)}'),
      trailing: Text('${e.min} min', style: const TextStyle(fontSize: 15)),
    );
  }
}
