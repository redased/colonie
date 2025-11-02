import 'user_type.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserType userType;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Director specific fields
  final List<String>? diplomas;
  final List<String>? experiences;
  final DateTime? stageStartDate;
  final DateTime? stageEndDate;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
    this.dateOfBirth,
    this.phoneNumber,
    this.profileImageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.diplomas,
    this.experiences,
    this.stageStartDate,
    this.stageEndDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Gérer le cas où l'API retourne userType comme string
    UserType userType = UserType.parent;
    if (json['userType'] != null) {
      final userTypeStr = json['userType'].toString();
      try {
        userType = UserType.values.firstWhere(
          (type) => type.name == userTypeStr || type.toString() == 'UserType.$userTypeStr',
        );
      } catch (e) {
        // Garder parent par défaut si le type n'est pas reconnu
        userType = UserType.parent;
      }
    }

    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      userType: userType,
      dateOfBirth: json['dateOfBirth'] != null || json['date_of_birth'] != null
          ? DateTime.parse(json['dateOfBirth'] ?? json['date_of_birth'])
          : null,
      phoneNumber: json['phoneNumber'] ?? json['phone_number'],
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
      diplomas: json['diplomas'] != null
          ? List<String>.from(json['diplomas'])
          : null,
      experiences: json['experiences'] != null
          ? List<String>.from(json['experiences'])
          : null,
      stageStartDate: json['stageStartDate'] != null
          ? DateTime.parse(json['stageStartDate'])
          : null,
      stageEndDate: json['stageEndDate'] != null
          ? DateTime.parse(json['stageEndDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'userType': userType.name,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'diplomas': diplomas,
      'experiences': experiences,
      'stageStartDate': stageStartDate?.toIso8601String(),
      'stageEndDate': stageEndDate?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    UserType? userType,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? diplomas,
    List<String>? experiences,
    DateTime? stageStartDate,
    DateTime? stageEndDate,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userType: userType ?? this.userType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      diplomas: diplomas ?? this.diplomas,
      experiences: experiences ?? this.experiences,
      stageStartDate: stageStartDate ?? this.stageStartDate,
      stageEndDate: stageEndDate ?? this.stageEndDate,
    );
  }

  String get fullName => '$firstName $lastName';

  // Getters pour faciliter l'accès selon le type d'utilisateur
  bool get isParent => userType == UserType.parent;
  bool get isDirector => userType == UserType.director;
  bool get isAnimator => userType == UserType.animator;
  bool get isAccountant => userType == UserType.accountant;

  // Obtenir les permissions basées sur le type d'utilisateur
  UserPermissions get permissions {
    switch (userType) {
      case UserType.parent:
        return UserPermissions(
          canViewChildren: true,
          canManageChildren: false,
          canViewActivities: true,
          canManageActivities: false,
          canViewUsers: false,
          canManageUsers: false,
          canViewFinances: false,
          canManageFinances: false,
        );
      case UserType.director:
        return UserPermissions(
          canViewChildren: true,
          canManageChildren: true,
          canViewActivities: true,
          canManageActivities: true,
          canViewUsers: true,
          canManageUsers: true,
          canViewFinances: true,
          canManageFinances: true,
        );
      case UserType.animator:
        return UserPermissions(
          canViewChildren: true,
          canManageChildren: false,
          canViewActivities: true,
          canManageActivities: true,
          canViewUsers: false,
          canManageUsers: false,
          canViewFinances: false,
          canManageFinances: false,
        );
      case UserType.accountant:
        return UserPermissions(
          canViewChildren: true,
          canManageChildren: false,
          canViewActivities: true,
          canManageActivities: false,
          canViewUsers: true,
          canManageUsers: false,
          canViewFinances: true,
          canManageFinances: true,
        );
    }
  }
}

class UserPermissions {
  final bool canViewChildren;
  final bool canManageChildren;
  final bool canViewActivities;
  final bool canManageActivities;
  final bool canViewUsers;
  final bool canManageUsers;
  final bool canViewFinances;
  final bool canManageFinances;

  UserPermissions({
    required this.canViewChildren,
    required this.canManageChildren,
    required this.canViewActivities,
    required this.canManageActivities,
    required this.canViewUsers,
    required this.canManageUsers,
    required this.canViewFinances,
    required this.canManageFinances,
  });
}