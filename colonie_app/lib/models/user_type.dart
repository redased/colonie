enum UserType {
  parent,
  director,
  animator,
  accountant,
}

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.parent:
        return 'Parent';
      case UserType.director:
        return 'Directeur';
      case UserType.animator:
        return 'Animateur';
      case UserType.accountant:
        return 'Comptable';
    }
  }

  String get frenchName {
    switch (this) {
      case UserType.parent:
        return 'Parent';
      case UserType.director:
        return 'Directeur';
      case UserType.animator:
        return 'Animateur';
      case UserType.accountant:
        return 'Économe/Comptable';
    }
  }
}