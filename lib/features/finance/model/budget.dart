import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String categoryid;

  @HiveField(1)
  final double allocatedAmount;

  BudgetModel({
    required this.categoryid,
    required this.allocatedAmount,
  });

  BudgetModel copyWith({
    String? categoryid,
    double? allocatedAmount,
  }) {
    return BudgetModel(
      categoryid: categoryid ?? this.categoryid,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
    );
  }
}
