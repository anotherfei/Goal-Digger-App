part of goal_digger;

/* -------------------------------------------------------------------------- */
/* HELPERS                                                                    */
/* -------------------------------------------------------------------------- */

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime addDays(DateTime date, int days) {
  return dateOnly(date).add(Duration(days: days));
}

int daysBetween(DateTime from, DateTime to) {
  return dateOnly(to).difference(dateOnly(from)).inDays;
}

String two(int n) => n.toString().padLeft(2, '0');

const List<String> monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String shortDate(DateTime date) => '${monthNames[date.month - 1]} ${date.day}';

String longDate(DateTime date) {
  return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
}

String dateKey(DateTime date) {
  final d = dateOnly(date);
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}
