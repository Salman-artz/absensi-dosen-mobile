class Student {
  final String id;
  final String nim;
  final String fullName;
  final String? className;
  final String? semester;

  Student({
    required this.id,
    required this.nim,
    required this.fullName,
    this.className,
    this.semester,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] ?? '',
        nim: json['nim'] ?? '',
        fullName: json['fullName'] ?? '',
        className: json['className'],
        semester: json['semester'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nim': nim,
        'fullName': fullName,
        if (className != null) 'className': className,
        if (semester != null) 'semester': semester,
      };
}

class ClassGroup {
  final String className;
  final String semester;
  final int totalStudents;

  ClassGroup({
    required this.className,
    required this.semester,
    required this.totalStudents,
  });

  factory ClassGroup.fromJson(Map<String, dynamic> json) => ClassGroup(
        className: json['className'] ?? '',
        semester: json['semester'] ?? '',
        totalStudents: json['totalStudents'] ?? 0,
      );
}
