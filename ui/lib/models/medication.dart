class Medication {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String unit;
  final String time;
  final List<String> days;
  bool taken;

  Medication({
    required this.id,
    required this.userId,
    required this.name,
    this.amount = 0,
    this.unit = '',
    required this.time,
    this.days = const [],
    this.taken = false,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      amount: json['amount'] ?? '',
      unit: json['unit'] ?? '',
      time: json['time'] ?? '',
      days: List<String>.from(json['days'] ?? []),
      taken: json['taken'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'amount': amount,
      'unit': unit,
      'time': time,
      'days': days,
      'taken': taken,
    };
  }
}
