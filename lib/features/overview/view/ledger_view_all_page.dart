import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mula/core/enum/transaction_type.dart';
import 'package:mula/features/finance/notifier/transaction_notifier.dart';
import 'package:mula/shared/theme/text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LedgerViewAllPage extends ConsumerWidget {
  const LedgerViewAllPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIconsRegular.arrowLeft, color: const Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Transactions Ledger',
          style: AppTextStyles.titleMedium.copyWith(color: const Color(0xFF1E293B)),
        ),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          t.type == TransactionType.income
                              ? PhosphorIconsRegular.wallet
                              : PhosphorIconsRegular.shoppingCart,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: AppTextStyles.titleMedium.copyWith(color: const Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat.yMd().format(t.date),
                              style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${t.type == TransactionType.income ? '+' : '-'} \$${t.amount.toStringAsFixed(2)}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: t.type == TransactionType.income
                              ? const Color(0xFF10B981)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading transactions')),
      ),
    );
  }
}

