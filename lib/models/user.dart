enum UserRole {
  restaurant,
  beneficiary,
  volunteer,
  donor,
}

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.restaurant:
        return 'مطعم';
      case UserRole.beneficiary:
        return 'مستفيد';
      case UserRole.volunteer:
        return 'متطوع';
      case UserRole.donor:
        return 'متبرع فردي';
    }
  }
}

UserRole userRoleFromString(String value) {
  return UserRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => UserRole.beneficiary,
  );
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      name: map['name'] as String,
      email: map['email'] as String,
      role: userRoleFromString(map['role'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
    };
  }
}
