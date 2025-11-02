import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import 'animator_dashboard_screen.dart';

class AnimatorHomeScreen extends StatelessWidget {
  final User user;

  const AnimatorHomeScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatorDashboardScreen(user: user);
  }
}