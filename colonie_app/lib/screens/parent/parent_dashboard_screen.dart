import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user.dart';
import '../../models/child.dart';
import '../../models/activity.dart' as activity_model;
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class ParentDashboardScreen extends StatefulWidget {
  final User user;

  const ParentDashboardScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  bool _isLoading = false;
  List<Child> _children = [];
  List<activity_model.Activity> _todayActivities = [];
  int _currentIndex = 0;

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
        _todayActivities = _getMockTodayActivities();
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
          'Espace Parent',
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: AppColors.parentColor,
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
          : _buildCurrentPage(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardPage();
      case 1:
        return _buildLocationPage();
      case 2:
        return _buildPlanningPage();
      case 3:
        return _buildPhotosPage();
      case 4:
        return _buildChildProfilePage();
      default:
        return _buildDashboardPage();
    }
  }

  Widget _buildDashboardPage() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          SizedBox(height: 24.h),
          _buildChildrenOverview(),
          SizedBox(height: 24.h),
          _buildQuickActions(),
          SizedBox(height: 24.h),
          _buildTodayActivities(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.parentColor,
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          colors: [AppColors.parentColor, AppColors.parentColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour, ${widget.user.firstName}!',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Suivez vos enfants en temps réel',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Enfants', '${_children.length}', Icons.child_care),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatCard('Activités', '${_todayActivities.length}', Icons.event),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
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
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes Enfants',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _children.length,
            itemBuilder: (context, index) {
              final child = _children[index];
              return _buildChildCard(child);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChildCard(Child child) {
    return Container(
      width: 200.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.parentColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.parentColor.withOpacity(0.1),
                child: Icon(
                  Icons.child_care,
                  color: AppColors.parentColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${child.firstName} ${child.lastName}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${child.age} ans',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.circle, color: Colors.green, size: 8.sp),
              SizedBox(width: 6.w),
              Text(
                'Actif',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                'Groupe: ${child.groupe}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.parentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              'Solde: €${child.availableMoney.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.parentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.2,
      children: [
        _buildActionCard(
          Icons.location_on,
          'Localisation',
          'Voir position',
          AppColors.infoColor,
          () => setState(() => _currentIndex = 1),
        ),
        _buildActionCard(
          Icons.calendar_today,
          'Planning',
          'Activités du jour',
          AppColors.successColor,
          () => setState(() => _currentIndex = 2),
        ),
        _buildActionCard(
          Icons.photo_library,
          'Photos',
          'Derniers souvenirs',
          AppColors.warningColor,
          () => setState(() => _currentIndex = 3),
        ),
        _buildActionCard(
          Icons.message,
          'Messages',
          'Communications',
          AppColors.errorColor,
          () => _showMessagesDialog(),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    String subtitle,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayActivities() {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activités du Jour',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  CustomButton(
                    text: 'Voir tout',
                    onPressed: () => setState(() => _currentIndex = 2),
                    backgroundColor: AppColors.parentColor,
                    height: 30.h,
                    fontSize: 12.sp,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  itemCount: _todayActivities.length,
                  itemBuilder: (context, index) {
                    final activity = _todayActivities[index];
                    return _buildActivityCard(activity);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(activity_model.Activity activity) {
    return Card(
      elevation: 1,
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
            size: 16.sp,
          ),
        ),
        title: Text(
          activity.title,
          style: TextStyle(
            fontSize: 14.sp,
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
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '${_formatTime(activity.startTime)} - ${_formatTime(activity.endTime)}',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: activity.status == activity_model.ActivityStatus.inProgress
                ? AppColors.warningColor.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            activity.status == activity_model.ActivityStatus.inProgress ? 'En cours' : 'À venir',
            style: TextStyle(
              fontSize: 9.sp,
              color: activity.status == activity_model.ActivityStatus.inProgress
                  ? AppColors.warningColor
                  : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPage() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Localisation des Enfants',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: _children.isEmpty
                ? Center(
                    child: Text(
                      'Aucun enfant à localiser',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _children.length,
                    itemBuilder: (context, index) {
                      final child = _children[index];
                      return _buildLocationCard(child);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(Child child) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.parentColor.withOpacity(0.1),
                  child: Icon(
                    Icons.child_care,
                    color: AppColors.parentColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${child.firstName} ${child.lastName}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.circle, color: Colors.green, size: 8.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'En ligne - Il y a 5 minutes',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              height: 150.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.parentColor.withOpacity(0.3)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.parentColor,
                          size: 40.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Centre de la Colonie',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.parentColor,
                          ),
                        ),
                        Text(
                          'Forêt communale, Zone A',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 16.sp, color: AppColors.textSecondary),
                SizedBox(width: 8.w),
                Text(
                  'Dernière mise à jour: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                CustomButton(
                  text: 'Rafraîchir',
                  onPressed: _loadDashboardData,
                  backgroundColor: AppColors.parentColor,
                  height: 30.h,
                  fontSize: 12.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningPage() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Planning Quotidien',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.builder(
              itemCount: _todayActivities.length,
              itemBuilder: (context, index) {
                final activity = _todayActivities[index];
                return _buildPlanningCard(activity, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanningCard(activity_model.Activity activity, int index) {
    final isCompleted = activity.status == activity_model.ActivityStatus.completed;
    final isCurrent = activity.status == activity_model.ActivityStatus.inProgress;

    return Card(
      elevation: isCurrent ? 6 : 2,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: isCurrent
            ? BorderSide(color: AppColors.warningColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.successColor
                        : isCurrent
                            ? AppColors.warningColor
                            : AppColors.infoColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 20.sp)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        activity.location,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.warningColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'EN COURS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 16.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text(
                  '${_formatTime(activity.startTime)} - ${_formatTime(activity.endTime)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (isCompleted)
                  Icon(Icons.check_circle, color: AppColors.successColor, size: 16.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosPage() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Galerie Photos',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.8,
              ),
              itemCount: _getMockPhotos().length,
              itemBuilder: (context, index) {
                final photo = _getMockPhotos()[index];
                return _buildPhotoCard(photo);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(Map<String, dynamic> photo) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.parentColor.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.photo,
                      color: AppColors.parentColor,
                      size: 40.sp,
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo['title'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    photo['date'],
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildProfilePage() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profils des Enfants',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.builder(
              itemCount: _children.length,
              itemBuilder: (context, index) {
                final child = _children[index];
                return _buildChildProfileCard(child);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildProfileCard(Child child) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppColors.parentColor.withOpacity(0.1),
                  child: Icon(
                    Icons.child_care,
                    color: AppColors.parentColor,
                    size: 30.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${child.firstName} ${child.lastName}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${child.age} ans • Groupe ${child.groupe}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit, color: AppColors.parentColor, size: 20.sp),
              ],
            ),
            SizedBox(height: 16.h),
            _buildProfileRow('Date de naissance', '${child.dateDeNaissance.day}/${child.dateDeNaissance.month}/${child.dateDeNaissance.year}'),
            _buildProfileRow('Groupe', child.groupe ?? 'Non défini'),
            _buildProfileRow('Solde disponible', '€${child.availableMoney.toStringAsFixed(2)}', Colors.green),
            _buildProfileRow('Allergies', 'Aucune connue'),
            _buildProfileRow('Contact d\'urgence', '06 12 34 56 78'),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Consulter planning',
                    onPressed: () => setState(() => _currentIndex = 2),
                    backgroundColor: AppColors.infoColor,
                    height: 35.h,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: 'Voir photos',
                    onPressed: () => setState(() => _currentIndex = 3),
                    backgroundColor: AppColors.successColor,
                    height: 35.h,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.parentColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on),
          label: 'Localisation',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Planning',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library),
          label: 'Photos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.child_care),
          label: 'Profil',
        ),
      ],
    );
  }

  List<Child> _getMockChildren() {
    final now = DateTime.now();
    return [
      Child(
        id: '1',
        firstName: 'Lucas',
        lastName: 'Martin',
        dateDeNaissance: DateTime(2015, 6, 15),
        groupe: 'group-1',
        availableMoney: 150.00,
        createdAt: now,
        updatedAt: now,
      ),
      Child(
        id: '2',
        firstName: 'Emma',
        lastName: 'Dubois',
        dateDeNaissance: DateTime(2016, 3, 22),
        groupe: 'group-2',
        availableMoney: 200.00,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  List<activity_model.Activity> _getMockTodayActivities() {
    final now = DateTime.now();
    return [
      activity_model.Activity(
        id: '1',
        title: 'Petit-déjeuner',
        description: 'Petit-déjeuner collectif',
        dates: activity_model.DateTimeRange(
          start: DateTime(now.year, now.month, now.day, 8, 0),
          end: DateTime(now.year, now.month, now.day, 9, 0),
        ),
        location: 'Salle à manger',
        status: activity_model.ActivityStatus.completed,
        participants: ['1', '2'],
        createdAt: now,
        updatedAt: now,
      ),
      activity_model.Activity(
        id: '2',
        title: 'Chasse au Trésor',
        description: 'Grande chasse au trésor dans la forêt',
        dates: activity_model.DateTimeRange(
          start: DateTime(now.year, now.month, now.day, 9, 30),
          end: DateTime(now.year, now.month, now.day, 12, 0),
        ),
        location: 'Forêt communale',
        status: activity_model.ActivityStatus.inProgress,
        participants: ['1', '2'],
        createdAt: now,
        updatedAt: now,
      ),
      activity_model.Activity(
        id: '3',
        title: 'Cours de Natation',
        description: 'Cours de natation pour les enfants',
        dates: activity_model.DateTimeRange(
          start: DateTime(now.year, now.month, now.day, 14, 0),
          end: DateTime(now.year, now.month, now.day, 16, 0),
        ),
        location: 'Piscine municipale',
        status: activity_model.ActivityStatus.planned,
        participants: ['2'],
        createdAt: now,
        updatedAt: now,
      ),
      activity_model.Activity(
        id: '4',
        title: 'Goûter',
        description: 'Goûter et temps libre',
        dates: activity_model.DateTimeRange(
          start: DateTime(now.year, now.month, now.day, 16, 30),
          end: DateTime(now.year, now.month, now.day, 17, 0),
        ),
        location: 'Salle commune',
        status: activity_model.ActivityStatus.planned,
        participants: ['1', '2'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  List<Map<String, dynamic>> _getMockPhotos() {
    return [
      {'title': 'Chasse au trésor', 'date': 'Aujourd\'hui, 10:30'},
      {'title': 'Cours de natation', 'date': 'Hier, 14:00'},
      {'title': 'Goûter collectif', 'date': 'Hier, 16:30'},
      {'title': 'Jeux de société', 'date': '2 jours'},
      {'title': 'Promenade en forêt', 'date': '3 jours'},
      {'title': 'Atelier dessin', 'date': '4 jours'},
    ];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showMessagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Messages'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.message, color: AppColors.parentColor),
              title: Text('Nouveau message de la direction'),
              subtitle: Text('Rappel: sortie demain...'),
            ),
            const ListTile(
              leading: Icon(Icons.photo, color: AppColors.successColor),
              title: Text('Nouvelles photos disponibles'),
              subtitle: Text('Voir les dernières activités...'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    Navigator.of(context).pushReplacementNamed('/login');
  }
}