// lib/widgets/stat_widget.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget kotak statistik (Total / Dikerjakan / Selesai)
class StatWidget extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color bgColor;

  const StatWidget({
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style:
                  TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
