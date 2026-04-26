import 'package:rrule/rrule.dart';
void main() {
  final rule1 = RecurrenceRule(frequency: Frequency.daily);
  final rule2 = RecurrenceRule(frequency: Frequency.weekly);
  final rule3 = RecurrenceRule(frequency: Frequency.monthly);
  final rule4 = RecurrenceRule(frequency: Frequency.yearly);
  print(rule1);
  print(rule2);
  print(rule3);
  print(rule4);
}
