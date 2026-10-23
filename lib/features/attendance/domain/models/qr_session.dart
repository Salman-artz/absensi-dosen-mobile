class QrSession {
  final String token;
  final DateTime expiresAt;

  QrSession({required this.token, required this.expiresAt});

  factory QrSession.fromJson(Map<String, dynamic> json) => QrSession(
        token: json['token'] ?? '',
        expiresAt: DateTime.parse(json['expiresAt']),
      );
}
