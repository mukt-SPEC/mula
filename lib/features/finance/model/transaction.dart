import 'package:hive/hive.dart';
import 'package:mula/core/enum/transaction_type.dart';
import 'package:mula/features/finance/model/category_model.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final TransactionType type;

  // Nullable because 'income' might not need a category
  @HiveField(5)
  final String? categoryid;

  @HiveField(6)
  final bool isRecurring;

  // The RRULE string from the recurrence package
  @HiveField(7)
  final String? recurrenceRule;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.categoryid,
    this.isRecurring = false,
    this.recurrenceRule,
  });

  // Optional but helpful: A copyWith method makes updating state in Riverpod much easier
  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? categoryid,
    bool? isRecurring,
    String? recurrenceRule,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      categoryid: categoryid ?? this.categoryid,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
    );
  }
}
