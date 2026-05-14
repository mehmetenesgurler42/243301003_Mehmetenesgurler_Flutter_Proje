class LogModel {
  final String id;
  final String userId;
  final String action;
  final String details;
  final DateTime createdAt;

  LogModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.details,
    required this.createdAt,
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['id'],
      userId: map['user_id'],
      action: map['action'],
      details: map['details'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
