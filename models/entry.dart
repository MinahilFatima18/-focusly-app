
class Entry {
  final String title, type; // type: Focus / Short break / Long break / Skipped
  final int min;
  final DateTime time;
  Entry(this.title, this.type, this.min, this.time);
}
