import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryData {
  final int? id;
  final String name;
  final String type;
  final String iconKey;
  final Color color;

  const CategoryData({
    this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.color,
  });
}

const List<CategoryData> defaultCategories = [
  CategoryData(name: 'Gaji', type: 'income', iconKey: 'briefcase', color: AppColors.success),
  CategoryData(name: 'Freelance', type: 'income', iconKey: 'laptop', color: AppColors.success),
  CategoryData(name: 'Investasi', type: 'income', iconKey: 'trend_up', color: AppColors.primary),
  CategoryData(name: 'Lainnya (Pemasukan)', type: 'income', iconKey: 'plus_circle', color: AppColors.accent),
  CategoryData(name: 'Makanan & Minuman', type: 'expense', iconKey: 'fork_knife', color: AppColors.warning),
  CategoryData(name: 'Transportasi', type: 'expense', iconKey: 'car', color: AppColors.success),
  CategoryData(name: 'Belanja', type: 'expense', iconKey: 'shopping_cart', color: AppColors.warning),
  CategoryData(name: 'Tagihan & Utilitas', type: 'expense', iconKey: 'receipt', color: AppColors.accent),
  CategoryData(name: 'Kesehatan', type: 'expense', iconKey: 'heart', color: AppColors.danger),
  CategoryData(name: 'Hiburan', type: 'expense', iconKey: 'game_controller', color: AppColors.accent),
  CategoryData(name: 'Pendidikan', type: 'expense', iconKey: 'book', color: AppColors.primary),
  CategoryData(name: 'Lainnya (Pengeluaran)', type: 'expense', iconKey: 'dots_three', color: AppColors.grayText),
];

const Map<String, Color> categoryColorMap = {
  'briefcase': AppColors.success,
  'laptop': AppColors.success,
  'trend_up': AppColors.primary,
  'plus_circle': AppColors.accent,
  'fork_knife': AppColors.warning,
  'car': AppColors.success,
  'shopping_cart': AppColors.warning,
  'receipt': AppColors.accent,
  'heart': AppColors.danger,
  'game_controller': AppColors.accent,
  'book': AppColors.primary,
  'dots_three': AppColors.grayText,
};
