import '../models/user_type.dart';

class DemoAccounts {
  static const List<DemoAccount> accounts = [
    DemoAccount(
      email: 'parent@colonie.com',
      password: 'password123',
      firstName: 'Fatima',
      lastName: 'Bennani',
      userType: UserType.parent,
      description: 'Accès Parent - رؤية أطفالي',
    ),
    DemoAccount(
      email: 'directeur@colonie.com',
      password: 'password123',
      firstName: 'Mohammed',
      lastName: 'Alami',
      userType: UserType.director,
      description: 'Accès Directeur - الإدارة الكاملة',
    ),
    DemoAccount(
      email: 'animateur@colonie.com',
      password: 'password123',
      firstName: 'Youssef',
      lastName: 'Mansouri',
      userType: UserType.animator,
      description: 'Accès Animateur - إدارة الأنشطة',
    ),
    DemoAccount(
      email: 'comptable@colonie.com',
      password: 'password123',
      firstName: 'Amina',
      lastName: 'Kadiri',
      userType: UserType.accountant,
      description: 'Accès Comptable - الإدارة المالية',
    ),
  ];

  static DemoAccount? getAccountByType(UserType userType) {
    try {
      return accounts.firstWhere((account) => account.userType == userType);
    } catch (e) {
      return null;
    }
  }
}

class DemoAccount {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final UserType userType;
  final String description;

  const DemoAccount({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.userType,
    required this.description,
  });

  String get fullName => '$firstName $lastName';
}