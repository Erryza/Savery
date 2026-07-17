class GoalContribution {
  final int? id;
  final int goalId;
  final double amount;
  final String date; // ISO date

  const GoalContribution({
    this.id,
    required this.goalId,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'goal_id': goalId,
    'amount': amount,
    'date': date,
  };

  factory GoalContribution.fromMap(Map<String, dynamic> m) => GoalContribution(
    id: m['id'] as int?,
    goalId: m['goal_id'] as int,
    amount: (m['amount'] as num).toDouble(),
    date: m['date'] as String,
  );
}
