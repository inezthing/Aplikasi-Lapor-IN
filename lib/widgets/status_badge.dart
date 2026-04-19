import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;

  const StatusBadge({required this.status, this.small = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppStatus.getBgColor(status),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        AppStatus.getLabel(status),
        style: TextStyle(
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
          color: AppStatus.getColor(status),
        ),
      ),
    );
  }
}
