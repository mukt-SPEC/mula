import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mula/features/finance/notifier/budget_notifier.dart';
import 'package:mula/features/finance/notifier/category_notifier.dart';
import 'package:mula/shared/theme/text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NewCategoryPage extends ConsumerStatefulWidget {
  final String? existingCategoryId;
  final String? prefillName;
  final IconData? prefillIcon;

  const NewCategoryPage({
    super.key,
    this.existingCategoryId,
    this.prefillName,
    this.prefillIcon,
  });

  @override
  ConsumerState<NewCategoryPage> createState() => _NewCategoryPageState();
}

class _NewCategoryPageState extends ConsumerState<NewCategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  bool _isSaving = false;

  final List<IconData> _iconOptions = [
    Icons.shopping_bag,
    Icons.directions_car,
    Icons.home,
    Icons.fastfood,
    Icons.favorite,
    Icons.sports_esports,
    Icons.flight,
    Icons.computer,
    Icons.school,
    Icons.pets,
    Icons.local_cafe,
    Icons.water_drop,
    Icons.bolt,
    Icons.card_giftcard,
  ];

  late IconData _selectedIcon;

  bool get _isExisting => widget.existingCategoryId != null;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.prefillIcon ?? _iconOptions.first;
    if (widget.prefillName != null) {
      _nameController.text = widget.prefillName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final budgetText = _budgetController.text.trim();
    final budgetAmount =
        budgetText.isEmpty ? 0.0 : (double.tryParse(budgetText) ?? 0.0);

    if (_isExisting) {
      if (budgetAmount > 0) {
        await ref
            .read(budgetNotifierProvider.notifier)
            .setBudget(widget.existingCategoryId!, budgetAmount);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              budgetAmount > 0
                  ? 'Budget updated for ${widget.prefillName ?? name}!'
                  : 'No budget amount entered.',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    final createdCat = await ref
        .read(categoryNotifierProvider.notifier)
        .addCustomCategory(name, _selectedIcon.codePoint, 0xFF021742);

    if (createdCat == null) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('A category named "$name" already exists!')),
        );
      }
      return;
    }

    if (budgetAmount > 0) {
      await ref
          .read(budgetNotifierProvider.notifier)
          .setBudget(createdCat.id, budgetAmount);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIconsRegular.arrowLeft,
              color: const Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isExisting ? 'Set Budget' : 'New Category',
          style: AppTextStyles.titleMedium
              .copyWith(color: const Color(0xFF022A72), fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CATEGORY NAME',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF94A3B8), letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: _isExisting
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: _isExisting
                            ? Border.all(color: const Color(0xFFE2E8F0))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(PhosphorIconsRegular.tag,
                              color: const Color(0xFF64748B), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              readOnly: _isExisting,
                              style: AppTextStyles.bodyLarge
                                  .copyWith(color: const Color(0xFF1E293B)),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'e.g. Groceries',
                                hintStyle: AppTextStyles.bodyLarge
                                    .copyWith(color: const Color(0xFFCBD5E1)),
                              ),
                            ),
                          ),
                          if (_isExisting)
                            const Icon(Icons.lock_outline,
                                color: Color(0xFFCBD5E1), size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'CHOOSE AN ICON',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF94A3B8), letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _iconOptions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final iconData = _iconOptions[index];
                          final isSelected = _selectedIcon == iconData;
                          return GestureDetector(
                            onTap: _isExisting
                                ? null
                                : () =>
                                    setState(() => _selectedIcon = iconData),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF021742)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                iconData,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    if (!_isExisting) ...[
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Icon(PhosphorIconsRegular.list,
                              color: const Color(0xFF64748B), size: 20),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NOTES',
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: const Color(0xFF94A3B8),
                                      letterSpacing: 1.5),
                                ),
                                TextField(
                                  controller: _notesController,
                                  style: AppTextStyles.bodyLarge
                                      .copyWith(color: const Color(0xFF0F172A)),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'What was this for?',
                                    hintStyle: AppTextStyles.bodyLarge
                                        .copyWith(
                                            color: const Color(0xFF94A3B8)),
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
                          'CATEGORY BUDGET',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 1.5),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'USD',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Leave blank for no spending limit.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$ ',
                          style: AppTextStyles.displayMedium.copyWith(
                              color: const Color(0xFFCBD5E1),
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _budgetController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*')),
                            ],
                            style: AppTextStyles.displayLarge.copyWith(
                                color: const Color(0xFF022A72),
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0.00',
                              hintStyle: AppTextStyles.displayLarge.copyWith(
                                  color: const Color(0xFF022A72),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF022A72),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF022A72).withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isExisting ? 'Set Budget' : 'Save Up!',
                        style: AppTextStyles.titleMedium,
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

