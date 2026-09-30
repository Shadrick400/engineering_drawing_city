class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'student' or 'admin'
  final String? photoUrl;
  final String? year;         // e.g. "Year 1", "Year 2", etc.
  final String? program;      // e.g. "Civil Engineering"
  final String? institution;  // e.g. "The Copperbelt University"
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.year,
    this.program,
    this.institution,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'student',
      photoUrl: data['photoUrl'],
      year: data['year'],
      program: data['program'],
      institution: data['institution'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'year': year,
      'program': program,
      'institution': institution,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}