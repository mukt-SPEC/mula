import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mula/features/analytics/view/insight.dart';
import 'package:mula/features/finance/view/budgets_page.dart';
import 'package:mula/features/overview/view/overview_page.dart';
import 'package:mula/features/settings/views/settings_page.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const OverviewPage(),
    const BudgetsPage(),
    const InsightPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: PhosphorIcon(PhosphorIconsRegular.gridFour),
            activeIcon: PhosphorIcon(PhosphorIconsFill.gridFour),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: PhosphorIcon(PhosphorIconsRegular.wallet),
            activeIcon: PhosphorIcon(PhosphorIconsFill.wallet),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: PhosphorIcon(PhosphorIconsRegular.chartDonut),
            activeIcon: PhosphorIcon(PhosphorIconsFill.chartDonut),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: PhosphorIcon(PhosphorIconsRegular.gear),
            activeIcon: PhosphorIcon(PhosphorIconsFill.gear),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

