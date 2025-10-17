class SupportRequest {
  final String employeeId;
  final String message;
  final DateTime timestamp;

  SupportRequest({
    required this.employeeId,
    required this.message,
    required this.timestamp,
  });

  factory SupportRequest.fromMap(Map<String, dynamic> map) {
    return SupportRequest(
      employeeId: map['employee_id'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'type': 'support_request',
    'employee_id': employeeId,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
  };
}
