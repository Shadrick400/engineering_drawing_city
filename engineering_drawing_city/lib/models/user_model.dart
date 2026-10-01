class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'student' or 'admin'
  final String? photoUrl;
  final String? year;         // e.g. "Year 1", "Year 2", etc.
  final String? program;      // e.g. "Civil Engineering"
  final String? institution;  // e.g. "The Copperbelt University"
  final String? phoneNumber;  // mobile money / contact number
  final String? deviceId;     // registered device fingerprint (for device-lock)
  final bool isSuspended;     // true when device change or terms violation detected
  final String? suspensionReason; // details of the violation (e.g. Terms & Conditions breach)
  final DateTime? suspendedAt;
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
    this.phoneNumber,
    this.deviceId,
    this.isSuspended = false,
    this.suspensionReason,
    this.suspendedAt,
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
      phoneNumber: data['phoneNumber'],
      deviceId: data['deviceId'],
      isSuspended: data['isSuspended'] ?? false,
      suspensionReason: data['suspensionReason'],
      suspendedAt: data['suspendedAt'] != null
          ? DateTime.parse(data['suspendedAt'])
          : null,
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
      'phoneNumber': phoneNumber,
      'deviceId': deviceId,
      'isSuspended': isSuspended,
      'suspensionReason': suspensionReason,
      'suspendedAt': suspendedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? photoUrl,
    String? year,
    String? program,
    String? institution,
    String? phoneNumber,
    String? deviceId,
    bool? isSuspended,
    String? suspensionReason,
    DateTime? suspendedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearSuspensionReason = false,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      year: year ?? this.year,
      program: program ?? this.program,
      institution: institution ?? this.institution,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deviceId: deviceId ?? this.deviceId,
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionReason: clearSuspensionReason ? null : (suspensionReason ?? this.suspensionReason),
      suspendedAt: clearSuspensionReason ? null : (suspendedAt ?? this.suspendedAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}