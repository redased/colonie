class Child {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateDeNaissance;
  final String? groupe;
  final List<String> parents;
  final List<String> medicalConditions;
  final double availableMoney;
  final String? profileImageUrl;
  final bool isPresent;
  final DateTime createdAt;
  final DateTime updatedAt;

  Child({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateDeNaissance,
    this.groupe,
    this.parents = const [],
    this.medicalConditions = const [],
    this.availableMoney = 0.0,
    this.profileImageUrl,
    this.isPresent = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      dateDeNaissance: DateTime.parse(json['dateDeNaissance']),
      groupe: json['groupe'],
      parents: json['parents'] != null
          ? List<String>.from(json['parents'])
          : [],
      medicalConditions: json['medicalConditions'] != null
          ? List<String>.from(json['medicalConditions'])
          : [],
      availableMoney: (json['availableMoney'] ?? 0.0).toDouble(),
      profileImageUrl: json['profileImageUrl'],
      isPresent: json['isPresent'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateDeNaissance': dateDeNaissance.toIso8601String(),
      'groupe': groupe,
      'parents': parents,
      'medicalConditions': medicalConditions,
      'availableMoney': availableMoney,
      'profileImageUrl': profileImageUrl,
      'isPresent': isPresent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Child copyWith({
    String? id,
    String? firstName,
    String? lastName,
    DateTime? dateDeNaissance,
    String? groupe,
    List<String>? parents,
    List<String>? medicalConditions,
    double? availableMoney,
    String? profileImageUrl,
    bool? isPresent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Child(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateDeNaissance: dateDeNaissance ?? this.dateDeNaissance,
      groupe: groupe ?? this.groupe,
      parents: parents ?? this.parents,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      availableMoney: availableMoney ?? this.availableMoney,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isPresent: isPresent ?? this.isPresent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => '$firstName $lastName';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateDeNaissance.year;
    if (now.month < dateDeNaissance.month ||
        (now.month == dateDeNaissance.month && now.day < dateDeNaissance.day)) {
      age--;
    }
    return age;
  }
}