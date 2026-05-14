enum UserRole { donor, requester, admin }

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? bloodType;
  final int? age;
  final bool? hasDiseases;
  final String? diseaseDetails;
  final bool? isSmoker;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.bloodType,
    this.age,
    this.hasDiseases,
    this.diseaseDetails,
    this.isSmoker,
    required this.createdAt,
  });

  /// Profil tamamlanmış mı? (kan grubu, yaş, sigara durumu girilmiş mi?)
  bool get isProfileComplete =>
      bloodType != null && 
      bloodType!.isNotEmpty && 
      age != null && 
      isSmoker != null;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      fullName: map['full_name'] ?? '',
      role: _parseRole(map['role']),
      bloodType: map['blood_type'],
      age: map['age'],
      hasDiseases: map['has_diseases'],
      diseaseDetails: map['disease_details'],
      isSmoker: map['is_smoker'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  static UserRole _parseRole(String? role) => parseRoleFromString(role);

  static UserRole parseRoleFromString(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'donor':
        return UserRole.donor;
      default:
        return UserRole.requester;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.name,
      'blood_type': bloodType,
      'age': age,
      'has_diseases': hasDiseases,
      'disease_details': diseaseDetails,
      'is_smoker': isSmoker,
    };
  }
}
