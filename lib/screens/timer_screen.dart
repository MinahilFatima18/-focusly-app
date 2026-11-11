import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../state/app_state.dart';
import '../utils/helpers.dart';
import '../widgets/ring_painter.dart';

enum TimerMode { focus, shortBreak, longBreak }

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  TimerMode _mode = TimerMode.focus;
  int _secondsLeft = app.focus * 60;
  bool _isRunning = false;
  int _session = 1;
  Timer? _ticker;
  String _snap = '';

  int _dur(TimerMode m) =>
      (m == TimerMode.focus ? app.focus : m == TimerMode.shortBreak ? app.shortB : app.longB) * 60;
  int get _totalSeconds => _dur(_mode);
  bool get _isFocus => _mode == TimerMode.focus;
  Color get _color => _isFocus ? kPrimary : kTertiary;

  @override
  void initState() {
    super.initState();
    _snap = _sig();
    app.addListener(_onSettings);
  }

  String _sig() => '${app.focus}-${app.shortB}-${app.longB}-${app.longAfter}';

  // when durations are changed in Settings, update the idle timer
  void _onSettings() {
    if (_sig() == _snap) return;
    _snap = _sig();
    if (_isRunning) return;
    setState(() {
      _secondsLeft = _totalSeconds;
      if (_session > app.longAfter) _session = 1;
    });
  }

  String _format(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  String get _label {
    if (!_isRunning && _secondsLeft == _totalSeconds && _isFocus) return 'READY';
    switch (_mode) {
      case TimerMode.focus:
        return 'FOCUS';
      case TimerMode.shortBreak:
        return 'SHORT BREAK';
      case TimerMode.longBreak:
        return 'LONG BREAK';
    }
  }

  void _selectMode(TimerMode mode) {
    _ticker?.cancel();
    setState(() {
      _mode = mode;
      _secondsLeft = _dur(mode);
      _isRunning = false;
    });
  }

  void _startOrPause() {
    if (_isRunning) {
      _ticker?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_secondsLeft > 1) {
          setState(() => _secondsLeft--);
        } else {
          _phaseFinished(true);
        }
      });
    }
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _secondsLeft = _totalSeconds;
      _isRunning = false;
    });
  }

  // called when countdown ends (natural = true) or Skip is pressed
  void _phaseFinished([bool natural = false]) {
    _ticker?.cancel();
    if (_isFocus) {
      app.log(app.task, 'Focus', app.focus); // save to history
      setState(() {
        _secondsLeft = 0;
        _isRunning = false;
      });
      app.autoBreak ? _startBreak() : _showCompleteDialog();
    } else {
      if (natural) {
        final short = _mode == TimerMode.shortBreak;
        app.log(short ? 'Short break' : 'Long break', short ? 'Short break' : 'Long break',
            short ? app.shortB : app.longB);
      }
      _goToNextFocus();
      if (natural && app.autoFocus) _startOrPause();
    }
  }

  void _goToNextFocus() {
    setState(() {
      _session = _session >= app.longAfter ? 1 : _session + 1;
      _mode = TimerMode.focus;
      _secondsLeft = _dur(TimerMode.focus);
      _isRunning = false;
    });
  }

  void _startBreak() {
    final b = _session >= app.longAfter ? TimerMode.longBreak : TimerMode.shortBreak;
    setState(() {
      _mode = b;
      _secondsLeft = _dur(b);
      _isRunning = false;
    });
    _startOrPause();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Focus session saved · ${app.focus} min'),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(label: 'View', textColor: const Color(0xFFFFB3AD), onPressed: () {}),
    ));
  }

  void _showCompleteDialog() {
    final breakMin = _session >= app.longAfter ? app.longB : app.shortB;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (d) => AlertDialog(
        backgroundColor: const Color(0xFFF5E4E1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        icon: const Icon(Icons.star, color: kPrimary),
        title: const Text('Focus session complete!'),
        content: Text("You've finished $_session of ${app.longAfter} sessions. Time for a $breakMin-minute break.",
            textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(d);
              _goToNextFocus();
            },
            child: const Text('Skip break', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(d);
              _startBreak();
            },
            style: FilledButton.styleFrom(backgroundColor: kPrimary),
            child: const Text('Start break'),
          ),
        ],
      ),
    );
  }

  // edit "Working on" task name
  void _editTask() {
    final c = TextEditingController(text: app.task);
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Working on'),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kPrimary),
            onPressed: () {
              if (c.text.trim().isNotEmpty) app.task = c.text.trim();
              Navigator.pop(d);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    app.removeListener(_onSettings);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIdle = !_isRunning && _secondsLeft == _totalSeconds && _isFocus;
    final progress = isIdle ? 0.0 : _secondsLeft / _totalSeconds;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          topBar('focusly'),
          _buildModeSelector(),
          const SizedBox(height: 28),
          SizedBox(
            width: 290,
            height: 290,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(290, 290),
                  painter: RingPainter(
                      progress: progress, color: _color, trackColor: kTrack, strokeWidth: 14, showDot: !isIdle),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_label,
                        style: TextStyle(color: _color, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 3)),
                    const SizedBox(height: 4),
                    Text(_format(_secondsLeft), style: const TextStyle(fontSize: 72, color: kTextDark)),
                    Text('of ${_format(_totalSeconds)}', style: const TextStyle(fontSize: 16, color: kTextGrey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Session $_session of ${app.longAfter}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kTextDark)),
          const SizedBox(height: 8),
          _buildSessionDots(),
          const SizedBox(height: 22),
          _buildControls(),
          const SizedBox(height: 24),
          _buildInfoCard(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(40)),
      child: Row(children: [
        _modeButton('Focus', TimerMode.focus, kPrimary),
        _modeButton('Short break', TimerMode.shortBreak, kTertiary),
        _modeButton('Long break', TimerMode.longBreak, kTertiary),
      ]),
    );
  }

  Widget _modeButton(String text, TimerMode mode, Color color) {
    final selected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectMode(mode),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: selected ? color : Colors.transparent, borderRadius: BorderRadius.circular(30)),
          child: Text(text,
              style: TextStyle(
                  color: selected ? Colors.white : kTextDark, fontWeight: FontWeight.w500, fontSize: 15)),
        ),
      ),
    );
  }

  Widget _buildSessionDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(app.longAfter, (i) {
        final cur = i == _session - 1;
        final done = i < _session - 1;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: cur ? 32 : 11,
          height: 11,
          decoration: BoxDecoration(
              color: (cur || done) ? kPrimary : const Color(0xFFD9D0CE),
              borderRadius: BorderRadius.circular(10)),
        );
      }),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _smallRoundButton(Icons.replay, _reset),
        const SizedBox(width: 22),
        GestureDetector(
          onTap: _startOrPause,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 92,
            height: 92,
            decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(_isFocus ? 46 : 30)),
            child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 44),
          ),
        ),
        const SizedBox(width: 22),
        _smallRoundButton(Icons.skip_next, () => _phaseFinished()),
      ],
    );
  }

  Widget _smallRoundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(color: kSurface, shape: BoxShape.circle),
        child: Icon(icon, color: kTextDark),
      ),
    );
  }

  Widget _buildInfoCard() {
    final small = _isFocus ? 'Working on' : 'Break tip';
    final big = _isFocus
        ? app.task
        : (_mode == TimerMode.shortBreak ? 'Stand up and stretch your legs' : 'Take a walk and rest your eyes');

    return GestureDetector(
      onTap: _isFocus ? _editTask : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE6D5D2))),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: _isFocus ? const Color(0xFFFFD9D5) : kTertiaryLight,
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(_isFocus ? Icons.check : Icons.coffee,
                  color: _isFocus ? kTextDark : const Color(0xFF00201C)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(small, style: const TextStyle(fontSize: 13, color: kTextGrey)),
                  const SizedBox(height: 2),
                  Text(big, style: const TextStyle(fontSize: 17, color: kTextDark)),
                ],
              ),
            ),
            if (_isFocus) const Icon(Icons.edit, size: 20, color: kTextDark),
          ],
        ),
      ),
    );
  }
}
