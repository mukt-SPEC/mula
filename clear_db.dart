import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk('categories');
  await Hive.deleteBoxFromDisk('transactions');
  await Hive.deleteBoxFromDisk('budgets');
  print('DONE');
}
