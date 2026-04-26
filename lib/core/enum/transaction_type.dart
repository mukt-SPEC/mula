import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'transaction_type.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,
}