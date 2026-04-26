import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LedgerCard extends StatelessWidget {
  final PhosphorIconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final Color? color;
  const LedgerCard({
    super.key,
    this.color,
    this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color ?? Color(0xfff7f7f7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhosphorIcon(icon, color: iconColor ?? Color(0xff7a7a7a)),
          SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

