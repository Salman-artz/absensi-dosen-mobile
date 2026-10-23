class Meeting {
  final String id;
  final String scheduleId;
  final int meetingNumber;
  final String type;
  final DateTime meetingDate;

  Meeting({
    required this.id,
    required this.scheduleId,
    required this.meetingNumber,
    required this.type,
    required this.meetingDate,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
        id: json['id'] ?? '',
        scheduleId: json['scheduleId'] ?? '',
        meetingNumber: json['meetingNumber'] ?? 1,
        type: json['type'] ?? 'REGULER',
        meetingDate: json['meetingDate'] != null
            ? DateTime.parse(json['meetingDate'])
            : DateTime.now(),
      );
}

class StudentAttendanceItem {
  final String studentId;
  final String fullName;
  final String nim;
  String status;

  StudentAttendanceItem({
    required this.studentId,
    required this.fullName,
    required this.nim,
    required this.status,
  });

  factory StudentAttendanceItem.fromJson(Map<String, dynamic> json) {
    final student = json['student'] ?? {};
    return StudentAttendanceItem(
      studentId: student['id'] ?? '',
      fullName: student['fullName'] ?? '',
      nim: student['nim'] ?? '',
      status: json['status'] ?? 'TIDAK_HADIR',
    );
  }

  Map<String, dynamic> toUpdateJson() => {
        'studentId': studentId,
        'status': status,
      };
}
