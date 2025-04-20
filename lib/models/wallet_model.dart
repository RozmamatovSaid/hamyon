class WalletModel {
  final int id;
  final String title;
  final DateTime date;
  final double cost;

  WalletModel({
    required this.id,
    required this.title,
    required this.date,
    required this.cost,
  });

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map["id"],
      title: map["title"],
      date: DateTime.parse(map["date"]),
      cost: map["cost"],
    );
  }

  Map<String, dynamic> toMap() {
    return {"title": title, "date": date.toString(), "cost": cost.toString()};
  }

  WalletModel copyWith({int? id, String? title, DateTime? date, double? cost}) {
    return WalletModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      cost: cost ?? this.cost,
    );
  }
}
