class Budget {
  final int? id;
  final int categoryId;
  final String month; // YYYY-MM
  final double limitAmount;

  // Joined
  final String? categoryName;
  final String? categoryIconKey;
  final String? categoryColorHex;
  final double? spent;

  const Budget({
    this.id,
    required this.categoryId,
    required this.month,
    required this.limitAmount,
    this.categoryName,
    this.categoryIconKey,
    this.categoryColorHex,
    this.spent,
  });

  double get spentAmount => spent ?? 0;
  double get remaining => limitAmount - spentAmount;
  double get percentage => limitAmount > 0 ? (spentAmount / limitAmount).clamp(0.0, 1.0) : 0;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'category_id': categoryId,
    'month': month,
    'limit_amount': limitAmount,
  };

  factory Budget.fromMap(Map<String, dynamic> m) => Budget(
    id: m['id'] as int?,
    categoryId: m['category_id'] as int,
    month: m['month'] as String,
    limitAmount: (m['limit_amount'] as num).toDouble(),
    categoryName: m['category_name'] as String?,
    categoryIconKey: m['icon_key'] as String?,
    categoryColorHex: m['color_hex'] as String?,
    spent: m['spent'] != null ? (m['spent'] as num).toDouble() : null,
  );

  Budget copyWith({int? id, int? categoryId, String? month, double? limitAmount}) =>
      Budget(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        month: month ?? this.month,
        limitAmount: limitAmount ?? this.limitAmount,
        categoryName: categoryName,
        categoryIconKey: categoryIconKey,
        categoryColorHex: categoryColorHex,
        spent: spent,
      );
}
