import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import 'accountant_dashboard_screen.dart';

class AccountantHomeScreen extends StatelessWidget {
  final User user;

  const AccountantHomeScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AccountantDashboardScreen(user: user);
  }
}