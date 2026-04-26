import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mula/core/enum/transaction_type.dart';
import 'package:mula/features/finance/model/budget.dart';
import 'package:mula/features/finance/model/category_model.dart';
import 'package:mula/features/finance/model/transaction.dart';
import 'package:mula/features/facial_liveness/liveness_check.dart';
import 'package:mula/root_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  
  await Hive.openBox<TransactionModel>('transactions_v2');
  await Hive.openBox<BudgetModel>('budgets_v2');
  
  await Hive.openBox<CategoryModel>('categories_v2');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     home: const LivenessCheckView(),
     //home: const RootScreen(),
    );
  }
}
