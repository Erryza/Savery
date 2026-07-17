class Account {
  final int? id;
  final String name;
  final double balance;
  final bool isMain;

  const Account({
    this.id,
    required this.name,
    required this.balance,
    this.isMain = false,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'balance': balance,
    'is_main': isMain ? 1 : 0,
  };

  factory Account.fromMap(Map<String, dynamic> m) => Account(
    id: m['id'] as int?,
    name: m['name'] as String,
    balance: (m['balance'] as num).toDouble(),
    isMain: (m['is_main'] as int) == 1,
  );

  Account copyWith({int? id, String? name, double? balance, bool? isMain}) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        isMain: isMain ?? this.isMain,
      );
}
