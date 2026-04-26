import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mula/core/enum/transaction_type.dart';
import 'package:mula/features/finance/model/category_model.dart';
import 'package:mula/features/finance/model/transaction.dart';
import 'package:mula/features/finance/notifier/category_notifier.dart';
import 'package:mula/features/finance/notifier/transaction_notifier.dart';
import 'package:mula/features/finance/utils/category_icon_resolver.dart';
import 'package:mula/shared/theme/text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:rrule/rrule.dart';

class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({super.key});

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage> {
  TransactionType _selectedType = TransactionType.expense;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  Frequency _recurringFrequency = Frequency.monthly;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    if (_selectedType == TransactionType.expense && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category for the expense')),
      );
      return;
    }

    if (_selectedType == TransactionType.expense) {
      final transactionsAsync = ref.read(transactionNotifierProvider);
      double availableWalletBalance = 0;
      if (transactionsAsync is AsyncData) {
        final transactions = transactionsAsync.value!;
        for (final t in transactions) {
          if (t.type == TransactionType.income) {
            availableWalletBalance += t.amount;
          } else {
            availableWalletBalance -= t.amount;
          }
        }
        if (amount > availableWalletBalance) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Expense cannot exceed your wallet balance (\$$availableWalletBalance)'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    final String newId = DateTime.now().millisecondsSinceEpoch.toString();

    String? ruleString;
    if (_isRecurring) {
      final rule = RecurrenceRule(frequency: _recurringFrequency);
      ruleString = rule.toString();
    }

    final newTransaction = TransactionModel(
      id: newId,
      title: _notesController.text.isNotEmpty ? _notesController.text : 'Transaction',
      amount: amount,
      date: _selectedDate,
      type: _selectedType,
      categoryid: _selectedType == TransactionType.expense ? _selectedCategory?.id : null,
      isRecurring: _isRecurring,
      recurrenceRule: ruleString,
    );

    ref.read(transactionNotifierProvider.notifier).addTransaction(newTransaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryNotifierProvider);

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
          'New Transaction',
          style: AppTextStyles.titleMedium.copyWith(color: const Color(0xFF1E293B)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = TransactionType.expense),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedType == TransactionType.expense
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: _selectedType == TransactionType.expense
                                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Expense',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: _selectedType == TransactionType.expense
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF64748B),
                              fontWeight: _selectedType == TransactionType.expense ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = TransactionType.income),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedType == TransactionType.income
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: _selectedType == TransactionType.income
                                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Income',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: _selectedType == TransactionType.income
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF64748B),
                                  fontWeight: _selectedType == TransactionType.income ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AMOUNT',
                          style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF94A3B8), letterSpacing: 1.5),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'USD',
                            style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      style: AppTextStyles.displayMedium.copyWith(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: AppTextStyles.displayMedium.copyWith(color: const Color(0xFFCBD5E1), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_selectedType == TransactionType.expense) ...[
                Text(
                  'CATEGORY',
                  style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF94A3B8), letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) return const SizedBox.shrink();
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: categories.map((cat) {
                        final isSelected = _selectedCategory?.id == cat.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            width: (MediaQuery.of(context).size.width - 48 - 24) / 3, 
                            height: 100,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF021742) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  resolveCategoryIcon(cat.iconCodePoint),
                                  color: isSelected ? Colors.white : const Color(0xFF0F172A),
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cat.name,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: isSelected ? Colors.white : const Color(0xFF0F172A),
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error loading categories'),
                ),
                const SizedBox(height: 32),
              ],

              InkWell(
                onTap: () async {
                  final newDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (newDate != null) {
                    setState(() => _selectedDate = newDate);
                  }
                },
                child: Row(
                  children: [
                    Icon(PhosphorIconsRegular.calendarBlank, color: const Color(0xFF64748B), size: 28),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          'DATE',
                          style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF94A3B8), letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.yMd().format(_selectedDate),
                          style: AppTextStyles.titleMedium.copyWith(color: const Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(PhosphorIconsRegular.list, color: const Color(0xFF64748B), size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NOTES',
                          style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF94A3B8), letterSpacing: 1.5),
                        ),
                        TextField(
                          controller: _notesController,
                          style: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'What was this for?',
                            hintStyle: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF94A3B8)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Icon(PhosphorIconsRegular.arrowsClockwise, color: const Color(0xFFCBD5E1), size: 28),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recurring Transaction',
                        style: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
                      ),
                      if (_isRecurring)
                        Text(
                          'Select frequency',
                          style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF94A3B8)),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Switch(
                    value: _isRecurring,
                    onChanged: (val) => setState(() => _isRecurring = val),
                    activeColor: const Color(0xFF0F172A),
                  ),
                ],
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Frequency>(
                      value: _recurringFrequency,
                      isExpanded: true,
                      icon: const Icon(PhosphorIconsRegular.caretDown, color: Color(0xFF64748B)),
                      items: const [
                        DropdownMenuItem(value: Frequency.daily, child: Text('Daily')),
                        DropdownMenuItem(value: Frequency.weekly, child: Text('Weekly')),
                        DropdownMenuItem(value: Frequency.monthly, child: Text('Monthly')),
                        DropdownMenuItem(value: Frequency.yearly, child: Text('Yearly')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _recurringFrequency = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF021742),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text('Save Transaction', style: AppTextStyles.titleMedium),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

