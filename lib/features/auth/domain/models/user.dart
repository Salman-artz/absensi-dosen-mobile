class User {
  final String userId;
  final String email;
  final String name;
  final String role;
  final String? nip;

  User({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    this.nip,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['id'] ?? json['userId'] ?? '',
        email: json['email'] ?? '',
        name: json['name'] ?? '',
        role: json['role'] ?? '',
        nip: json['nip'],
      );

  Map<String, dynamic> toJson() => {
        'id': userId,
        'email': email,
        'name': name,
        'role': role,
        if (nip != null) 'nip': nip,
      };
}
