import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mula/features/settings/model/settings.dart';
import 'package:mula/features/settings/widget/ledger_card.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final List<SettingsGroup> settingsGroup = [
    SettingsGroup(
      header: 'Security and access',
      settingItem: [
        SettingsItem(
          title: 'Biometrics',
          subtitle: 'FaceID or TouchID enabled',
          icon: PhosphorIcon(PhosphorIconsFill.fingerprint),
        ),
        SettingsItem(
          title: 'Account security',
          subtitle: 'Configure app and user security',
          icon: PhosphorIcon(PhosphorIconsFill.userGear),
        ),
        SettingsItem(
          title: 'Two-factor authentication',
          subtitle: 'Set-up two-factor authentication',
          icon: PhosphorIcon(PhosphorIconsFill.userGear),
        ),
      ],
    ),
    SettingsGroup(
      header: 'Data management',
      settingItem: [
        SettingsItem(
          title: 'Export data',
          subtitle: 'CSV, PDF, OR JSON',
          icon: PhosphorIcon(PhosphorIconsFill.fileArrowDown),
        ),
        SettingsItem(
          title: 'Cloud backup',
          subtitle: 'FaceID or TouchID enabled',
          icon: PhosphorIcon(PhosphorIconsFill.cloudArrowUp),
        ),
        SettingsItem(
          title: 'User analytics',
          subtitle: 'FaceID or TouchID enabled',
          icon: PhosphorIcon(PhosphorIconsFill.chartBar),
        ),
        SettingsItem(
          title: 'Custom report',
          subtitle: 'FaceID or TouchID enabled',
          icon: PhosphorIcon(PhosphorIconsFill.files),
        ),
      ],
    ),
    SettingsGroup(
      header: 'Preference',
      settingItem: [
        SettingsItem(
          title: 'Currency',
          subtitle: 'USD (\$)',
          icon: PhosphorIcon(PhosphorIconsFill.money),
        ),
        SettingsItem(
          title: 'Language',
          subtitle: 'English (US)',
          icon: PhosphorIcon(PhosphorIconsFill.globe),
        ),
        SettingsItem(
          title: 'Timezone',
          subtitle: 'UTC -5',
          icon: PhosphorIcon(PhosphorIconsFill.clock),
        ),
        SettingsItem(
          title: 'Help center',
          subtitle: 'FAQs and direct support',
          icon: PhosphorIcon(PhosphorIconsFill.headset),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,

      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xfff7f7f7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    CircleAvatar(),
                    Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alexander sterling',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Pro member',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: LedgerCard(
                      icon: PhosphorIconsBold.wallet,
                      title: 'Default ledger',
                      subtitle: 'Main savings',
                    ),
                  ),
                  Expanded(
                    child: LedgerCard(
                      icon: PhosphorIconsFill.star,
                      title: 'Upgrade to sovereign',
                      subtitle: 'Executive',
                      iconColor: Colors.white,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: settingsGroup.map((group) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.header,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(color: Color(0xffb9b9b9)),
                      ),
                      const SizedBox(height: 4),
                      ...group.settingItem.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: Color(0xfff7f7f7),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            leading: item.icon,
                            title: Text(item.title),
                            subtitle: Text(item.subtitle ?? ''),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: item.onTap,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

