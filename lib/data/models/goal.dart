class Goal {
  final int? id;
  final String title;
  final double targetAmount;
  final double collectedAmount;
  final String? iconOrImagePath;
  final String status; // ongoing | achieved
  final String? deadline;

  const Goal({
    this.id,
    required this.title,
    required this.targetAmount,
    this.collectedAmount = 0,
    this.iconOrImagePath,
    this.status = 'ongoing',
    this.deadline,
  });

  double get remaining => (targetAmount - collectedAmount).clamp(0, double.infinity);
  double get percentage => targetAmount > 0 ? (collectedAmount / targetAmount).clamp(0.0, 1.0) : 0;
  bool get isAchieved => status == 'achieved' || collectedAmount >= targetAmount;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'target_amount': targetAmount,
    'collected_amount': collectedAmount,
    'icon_or_image_path': iconOrImagePath,
    'status': collectedAmount >= targetAmount ? 'achieved' : status,
    'deadline': deadline,
  };

  factory Goal.fromMap(Map<String, dynamic> m) => Goal(
    id: m['id'] as int?,
    title: m['title'] as String,
    targetAmount: (m['target_amount'] as num).toDouble(),
    collectedAmount: (m['collected_amount'] as num).toDouble(),
    iconOrImagePath: m['icon_or_image_path'] as String?,
    status: m['status'] as String,
    deadline: m['deadline'] as String?,
  );

  Goal copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? collectedAmount,
    String? iconOrImagePath,
    String? status,
    String? deadline,
  }) =>
      Goal(
        id: id ?? this.id,
        title: title ?? this.title,
        targetAmount: targetAmount ?? this.targetAmount,
        collectedAmount: collectedAmount ?? this.collectedAmount,
        iconOrImagePath: iconOrImagePath ?? this.iconOrImagePath,
        status: status ?? this.status,
        deadline: deadline ?? this.deadline,
      );
}
