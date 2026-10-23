import 'package:absensi_dosen_mobile/features/master_data/domain/models/course.dart';
import 'package:absensi_dosen_mobile/features/master_data/domain/models/room.dart';
import 'package:absensi_dosen_mobile/features/auth/domain/models/user.dart';

class Schedule {
  final String scheduleId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String className;
  final String semester;
  final Course? course;
  final Room? room;
  final User? lecturer;

  Schedule({
    required this.scheduleId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.className,
    required this.semester,
    this.course,
    this.room,
    this.lecturer,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        scheduleId: json['id'] ?? json['scheduleId'] ?? '',
        dayOfWeek: json['dayOfWeek']?.toString() ?? '',
        startTime: json['startTime'] ?? '',
        endTime: json['endTime'] ?? '',
        className: json['className'] ?? '',
        semester: json['semester'] ?? '-',
        course: json['course'] != null ? Course.fromJson(json['course']) : null,
        room: json['room'] != null ? Room.fromJson(json['room']) : null,
        lecturer: json['lecturer'] != null ? User.fromJson(json['lecturer']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': scheduleId,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'className': className,
        'semester': semester,
        if (course != null) 'course': course!.toJson(),
        if (room != null) 'room': room!.toJson(),
        if (lecturer != null) 'lecturer': lecturer!.toJson(),
      };
}
