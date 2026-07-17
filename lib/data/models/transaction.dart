class Transaction {
  final int? id;
  final int accountId;
  final int categoryId;
  final String type; // income | expense
  final double amount;
  final String title;
  final String? note;
  final String date;
  final String? receiptImagePath;
  final String createdAt;

  // Joined fields (not stored)
  final String? categoryName;
  final String? categoryIconKey;
  final String? categoryColorHex;
  final String? accountName;

  const Transaction({
    this.id,
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.title,
    this.note,
    required this.date,
    this.receiptImagePath,
    required this.createdAt,
    this.categoryName,
    this.categoryIconKey,
    this.categoryColorHex,
    this.accountName,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'account_id': accountId,
    'category_id': categoryId,
    'type': type,
    'amount': amount,
    'title': title,
    'note': note,
    'date': date,
    'receipt_image_path': receiptImagePath,
    'created_at': createdAt,
  };

  factory Transaction.fromMap(Map<String, dynamic> m) => Transaction(
    id: m['id'] as int?,
    accountId: m['account_id'] as int,
    categoryId: m['category_id'] as int,
    type: m['type'] as String,
    amount: (m['amount'] as num).toDouble(),
    title: m['title'] as String,
    note: m['note'] as String?,
    date: m['date'] as String,
    receiptImagePath: m['receipt_image_path'] as String?,
    createdAt: m['created_at'] as String,
    categoryName: m['category_name'] as String?,
    categoryIconKey: m['icon_key'] as String?,
    categoryColorHex: m['color_hex'] as String?,
    accountName: m['account_name'] as String?,
  );
}
