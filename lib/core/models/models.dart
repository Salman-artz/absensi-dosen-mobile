class User {
  final String userId;
  final String email;
  final String name;
  final String role;

  User({required this.userId, required this.email, required this.name, required this.role});

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['id'] ?? json['userId'] ?? '',
        email: json['email'] ?? '',
        name: json['name'] ?? '',
        role: json['role'] ?? '',
      );
}

class Course {
  final String courseId;
  final String code;
  final String name;
  final int credits;

  Course({required this.courseId, required this.code, required this.name, required this.credits});

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        courseId: json['id'] ?? json['courseId'] ?? '',
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        credits: json['credits'] ?? 0,
      );
}

class Room {
  final String roomId;
  final String name;
  final int capacity;

  Room({required this.roomId, required this.name, required this.capacity});

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        roomId: json['id'] ?? json['roomId'] ?? '',
        name: json['name'] ?? '',
        capacity: json['capacity'] ?? 0,
      );
}

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
}
