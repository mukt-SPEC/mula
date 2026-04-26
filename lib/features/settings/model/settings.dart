import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SettingsItem {
  final String title;
  final String? subtitle;
  final PhosphorIcon icon;
  final Widget? page;
  final VoidCallback? onTap;

  SettingsItem({
    required this.title,
    this.onTap,
    this.page,
    this.subtitle,
    required this.icon,
  });
}

class SettingsGroup {
  final String header;

  final List<SettingsItem> settingItem;

  SettingsGroup({required this.header, required this.settingItem});
}
