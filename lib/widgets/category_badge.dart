import 'package:flutter/material.dart';
import '../core/constants/app_icons.dart';
import '../core/theme/app_theme.dart';

class CategoryBadge extends StatelessWidget {
  final String iconKey;
  final Color color;
  final double size;

  const CategoryBadge({
    super.key,
    required this.iconKey,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _iconData(iconKey),
        color: color,
        size: size * 0.5,
      ),
    );
  }

  static Color colorFromHex(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return AppColors.primary;
  }

  static IconData _iconData(String key) {
    switch (key) {
      case 'briefcase': return AppIcons.briefcase;
      case 'laptop': return AppIcons.laptop;
      case 'trend_up': return AppIcons.trendUp;
      case 'plus_circle': return AppIcons.plusCircle;
      case 'fork_knife': return AppIcons.forkKnife;
      case 'car': return AppIcons.car;
      case 'shopping_cart': return AppIcons.shoppingCart;
      case 'receipt': return AppIcons.receiptSmall;
      case 'heart': return AppIcons.heart;
      case 'game_controller': return AppIcons.gameController;
      case 'book': return AppIcons.book;
      case 'dots_three': return AppIcons.dotsThree;
      case 'airplane': return AppIcons.airplane;
      case 'ring': return AppIcons.diamond;
      case 'device_mobile': return AppIcons.deviceMobile;
      case 'house': return AppIcons.house;
      default: return AppIcons.tag;
    }
  }
}
