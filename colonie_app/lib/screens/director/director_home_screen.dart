import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import 'director_dashboard_screen.dart';

class DirectorHomeScreen extends StatelessWidget {
  final User user;

  const DirectorHomeScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DirectorDashboardScreen(user: user);
  }
}