import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'parent_dashboard_screen.dart';

class ParentHomeScreen extends StatelessWidget {
  final User user;

  const ParentHomeScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ParentDashboardScreen(user: user);
  }
}

class ParentDashboardPage extends StatelessWidget {
  const ParentDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue, Parent!',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Suivez vos enfants en temps réel',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 30.h),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              children: [
                _buildQuickAccessCard(
                  Icons.location_on,
                  'Localisation',
                  'Voir où se trouve votre enfant',
                  AppColors.parentColor,
                ),
                _buildQuickAccessCard(
                  Icons.calendar_today,
                  'Planning',
                  'Activités du jour',
                  AppColors.infoColor,
                ),
                _buildQuickAccessCard(
                  Icons.photo_library,
                  'Photos',
                  'Derniers souvenirs',
                  AppColors.successColor,
                ),
                _buildQuickAccessCard(
                  Icons.child_care,
                  'Profil',
                  'Informations de l\'enfant',
                  AppColors.warningColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40.sp,
              color: color,
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ParentLocationPage extends StatelessWidget {
  const ParentLocationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Page de localisation de l\'enfant',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class ParentPlanningPage extends StatelessWidget {
  const ParentPlanningPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Planning quotidien de l\'enfant',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class ParentPhotosPage extends StatelessWidget {
  const ParentPhotosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Galerie de photos',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class ParentChildProfilePage extends StatelessWidget {
  const ParentChildProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profil de l\'enfant',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}