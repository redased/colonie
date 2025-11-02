import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user.dart';
import '../../models/child.dart';
import '../../models/activity.dart' as activity_model;
import '../../models/user_type.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'children_management_screen.dart';
import 'staff_management_screen.dart';
import 'activities_management_screen.dart';
import 'registers_screen.dart';

class DirectorDashboardScreen extends StatefulWidget {
  final User user;

  const DirectorDashboardScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<DirectorDashboardScreen> createState() => _DirectorDashboardScreenState();
}

class _DirectorDashboardScreenState extends State<DirectorDashboardScreen> {
  bool _isLoading = false;
  List<Child> _children = [];
  List<activity_model.Activity> _activities = [];
  List<User> _staff = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _children = _getMockChildren();
        _activities = _getMockActivities();
        _staff = _getMockStaff();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tableau de Bord - Directeur',
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: AppColors.directorColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          SizedBox(height: 24.h),
          _buildStatsCards(),
          SizedBox(height: 24.h),
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.directorColor,
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          colors: [AppColors.directorColor, AppColors.directorColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue, ${widget.user.firstName}!',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Gestion Complète de la Colonie',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildStatCard('Enfants', '${_children.length}', Icons.child_care),
              SizedBox(width: 16.w),
              _buildStatCard('Animateurs', '${_staff.length}', Icons.people),
              SizedBox(width: 16.w),
              _buildStatCard('Activités', '${_activities.length}', Icons.event),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.2,
      children: [
        _buildManagementCard(
          Icons.child_care,
          'Gestion Enfants',
          '${_children.length} enfants',
          'Voir détails',
          AppColors.infoColor,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChildrenManagementScreen(user: widget.user),
              ),
            );
          },
        ),
        _buildManagementCard(
          Icons.people,
          'Gestion Personnel',
          '${_staff.length} animateurs',
          'Voir équipe',
          AppColors.successColor,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => StaffManagementScreen(user: widget.user),
              ),
            );
          },
        ),
        _buildManagementCard(
          Icons.event,
          'Gestion Activités',
          '${_activities.length} activités',
          'Planning',
          AppColors.warningColor,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ActivitiesManagementScreen(user: widget.user),
              ),
            );
          },
        ),
        _buildManagementCard(
          Icons.book,
          'Registres',
          '5 registres',
          'Consulter',
          AppColors.errorColor,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RegistersScreen(user: widget.user),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildManagementCard(
    IconData icon,
    String title,
    String subtitle,
    String buttonText,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 30.sp,
                  color: color,
                ),
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
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              CustomButton(
                text: buttonText,
                onPressed: onTap,
                backgroundColor: color,
                height: 32.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activités Récentes',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: _buildActivitiesList(),
          ),
          SizedBox(height: 16.h),
          CustomButton(
            text: 'Voir Toutes les Activités',
            onPressed: () {},
            icon: Icons.event_note,
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList() {
    return ListView.builder(
      itemCount: _activities.length.clamp(0, 3),
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildActivityCard(activity_model.Activity activity) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12.w),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: activity.status == activity_model.ActivityStatus.completed
                ? AppColors.successColor
                : activity.status == activity_model.ActivityStatus.inProgress
                    ? AppColors.warningColor
                    : AppColors.infoColor,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(
            Icons.event,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        title: Text(
          activity.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.location,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              activity.formattedDateRange,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        // Navigation simplifiée
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.directorColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Équipe',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Activités',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Statistiques',
        ),
      ],
    );
  }

  List<Child> _getMockChildren() {
    final now = DateTime.now();
    return [
      Child(
        id: '1',
        firstName: 'Yassine',
        lastName: 'Bennani',
        dateDeNaissance: DateTime(2015, 6, 15),
        groupe: 'group-1',
        availableMoney: 20000.00,
        createdAt: now,
        updatedAt: now,
      ),
      Child(
        id: '2',
        firstName: 'Amina',
        lastName: 'Alami',
        dateDeNaissance: DateTime(2016, 3, 22),
        groupe: 'group-2',
        availableMoney: 25000.00,
        createdAt: now,
        updatedAt: now,
      ),
      Child(
        id: '3',
        firstName: 'Omar',
        lastName: 'Mansouri',
        dateDeNaissance: DateTime(2015, 11, 8),
        groupe: 'group-1',
        availableMoney: 18000.00,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  List<activity_model.Activity> _getMockActivities() {
    final now = DateTime.now();
    return [
      activity_model.Activity(
        id: '1',
        title: 'البحث عن الكنز',
        description: 'بحث عن الكنز في الغابة مع الألغاز والتحديات',
        dates: activity_model.DateTimeRange(
          start: now.add(const Duration(days: 1, hours: 9)),
          end: now.add(const Duration(days: 1, hours: 12)),
        ),
        location: 'الغابة البلدية',
        status: activity_model.ActivityStatus.planned,
        participants: ['1', '2', '3'],
        createdAt: now,
        updatedAt: now,
      ),
      activity_model.Activity(
        id: '2',
        title: 'دورات السباحة',
        description: 'دورات السباحة للأطفال مع مدربين مؤهلين',
        dates: activity_model.DateTimeRange(
          start: now.add(const Duration(days: 1, hours: 14)),
          end: now.add(const Duration(days: 1, hours: 16)),
        ),
        location: 'مدينة السباحة',
        status: activity_model.ActivityStatus.inProgress,
        participants: ['2'],
        createdAt: now,
        updatedAt: now,
      ),
      activity_model.Activity(
        id: '3',
        title: 'المسرح',
        description: 'عرض مسرحي للأطفال',
        dates: activity_model.DateTimeRange(
          start: now.add(const Duration(days: 2, hours: 10)),
          end: now.add(const Duration(days: 2, hours: 12)),
        ),
        location: 'القاعة متعددة الأغراض',
        status: activity_model.ActivityStatus.completed,
        participants: ['1', '3'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  List<User> _getMockStaff() {
    final now = DateTime.now();
    return [
      User(
        id: '1',
        firstName: 'Youssef',
        lastName: 'Mansouri',
        userType: UserType.animator,
        email: 'youssef@colonie.com',
        createdAt: now,
        updatedAt: now,
      ),
      User(
        id: '2',
        firstName: 'Amina',
        lastName: 'Kadiri',
        userType: UserType.accountant,
        email: 'amina@colonie.com',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<void> _logout() async {
    Navigator.of(context).pushReplacementNamed('/login');
  }
}