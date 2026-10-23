class LeaveRequest {
  final String id;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final String lecturerName;

  LeaveRequest({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.lecturerName,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => LeaveRequest(
        id: json['id'] ?? '',
        type: json['type'] ?? 'IZIN',
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        reason: json['reason'] ?? '',
        status: json['status'] ?? 'PENDING',
        lecturerName: json['lecturer']?['name'] ?? 'Dosen',
      );
}
