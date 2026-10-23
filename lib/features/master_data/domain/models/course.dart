class Course {
  final String courseId;
  final String code;
  final String name;
  final int credits;

  Course({
    required this.courseId,
    required this.code,
    required this.name,
    required this.credits,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        courseId: json['id'] ?? json['courseId'] ?? '',
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        credits: json['credits'] ?? json['sks'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': courseId,
        'code': code,
        'name': name,
        'credits': credits,
      };
}
