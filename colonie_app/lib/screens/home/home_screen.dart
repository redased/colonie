import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/user_type.dart';
import '../parent/parent_home_screen.dart';
import '../director/director_home_screen.dart';
import '../animator/animator_home_screen.dart';
import '../accountant/accountant_home_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (user.userType) {
      case UserType.parent:
        return ParentHomeScreen(user: user);
      case UserType.director:
        return DirectorHomeScreen(user: user);
      case UserType.animator:
        return AnimatorHomeScreen(user: user);
      case UserType.accountant:
        return AccountantHomeScreen(user: user);
    }
  }
}