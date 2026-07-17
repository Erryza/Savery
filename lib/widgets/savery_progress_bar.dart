import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SaveryProgressBar extends StatelessWidget {
  final double value; // 0.0 - 1.0
  final double height;

  const SaveryProgressBar({super.key, required this.value, this.height = 8});

  Color get _color {
    if (value > 0.9) return AppColors.danger;
    if (value > 0.7) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: context.appLine,
        valueColor: AlwaysStoppedAnimation(_color),
      ),
    );
  }
}
