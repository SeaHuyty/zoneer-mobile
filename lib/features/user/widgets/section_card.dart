import 'package:flutter/material.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/core/utils/app_decoration.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppDecoration.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Divider(color: const Color(0xFFEAEAEA), height: 1),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}
// --------------------
// reusable InfoIconRow
// --------------------
class InfoIconRow extends StatelessWidget {
  const InfoIconRow({
    super.key,
    required this.text,
    required this.textColor,
    required this.rowIcon,
    required this.iconColor,
    this.textSize = 18,
    this.iconSize = 18,
  });

  final String text;
  final Color textColor;
  final IconData rowIcon;
  final Color iconColor;
  final double textSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(rowIcon, size: iconSize, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: textSize, color: textColor),
          ),
        ),
      ],
    );
  }
}
