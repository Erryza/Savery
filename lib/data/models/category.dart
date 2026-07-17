class Category {
  final int? id;
  final String name;
  final String type; // income | expense
  final String iconKey;
  final String colorHex;

  const Category({
    this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorHex,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'type': type,
    'icon_key': iconKey,
    'color_hex': colorHex,
  };

  factory Category.fromMap(Map<String, dynamic> m) => Category(
    id: m['id'] as int?,
    name: m['name'] as String,
    type: m['type'] as String,
    iconKey: m['icon_key'] as String,
    colorHex: m['color_hex'] as String,
  );

  Category copyWith({int? id, String? name, String? type, String? iconKey, String? colorHex}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        iconKey: iconKey ?? this.iconKey,
        colorHex: colorHex ?? this.colorHex,
      );
}
