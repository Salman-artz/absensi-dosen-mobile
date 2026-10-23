class AttendanceSummary {
  final int hadir;
  final int telat;
  final int izin;
  final int alpha;

  AttendanceSummary({
    required this.hadir,
    required this.telat,
    required this.izin,
    required this.alpha,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) => AttendanceSummary(
        hadir: json['HADIR'] ?? 0,
        telat: json['TELAT'] ?? 0,
        izin: json['IZIN'] ?? 0,
        alpha: json['ALPHA'] ?? 0,
      );
}
