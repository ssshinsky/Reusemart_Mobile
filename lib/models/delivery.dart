class Delivery {
  final int id;
  final String status;
  final String date;

  Delivery({
    required this.id,
    required this.status,
    required this.date,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
