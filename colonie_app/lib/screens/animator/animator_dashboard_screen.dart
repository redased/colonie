import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user.dart';
import '../../models/child.dart';
import '../../models/activity.dart' as activity_model;
import '../../models/user_type.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class AnimatorDashboardScreen extends StatefulWidget {
  final User user;

  const AnimatorDashboardScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<AnimatorDashboardScreen> createState() => _AnimatorDashboardScreenState();
}

class _AnimatorDashboardScreenState extends State<AnimatorDashboardScreen> {
  bool _isLoading = false;
  List<Child> _myGroupChildren = [];
  List<activity_model.Activity> _myActivities = [];
  List<Map<String, dynamic>> _resources = [];
  List<Map<String, dynamic>> _incidents = [];
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
        _myGroupChildren = _getMockChildren();
        _myActivities = _getMockActivities();
        _resources = _getMockResources();
        _incidents = _getMockIncidents();
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
          'Espace Animateur',
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: AppColors.animatorColor,
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
        return _buildInventoryPage();
      case 2:
        return _buildResourcesPage();
      case 3:
        return _buildIncidentsPage();
      case 4:
        return _buildGroupPage();
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
          _buildStatsCards(),
          SizedBox(height: 24.h),
          _buildTodaySchedule(),
          SizedBox(height: 24.h),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.animatorColor,
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          colors: [AppColors.animatorColor, AppColors.animatorColor.withOpacity(0.8)],
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
            'Gérez vos activités et votre groupe',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Enfants', '${_myGroupChildren.length}', Icons.child_care),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatCard('Activités', '${_myActivities.length}', Icons.event),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatCard('Incidents', '${_incidents.where((i) => i['status'] == 'open').length}', Icons.warning),
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
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
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
          Icons.inventory,
          'Inventaire',
          '${_myGroupChildren.length} enfants',
          'Gérer arrivée',
          AppColors.infoColor,
          () => setState(() => _currentIndex = 1),
        ),
        _buildManagementCard(
          Icons.music_note,
          'Ressources',
          '${_resources.length} disponibles',
          'Voir ressources',
          AppColors.successColor,
          () => setState(() => _currentIndex = 2),
        ),
        _buildManagementCard(
          Icons.report,
          'Incidents',
          '${_incidents.where((i) => i['status'] == 'open').length} ouverts',
          'Voir incidents',
          AppColors.warningColor,
          () => setState(() => _currentIndex = 3),
        ),
        _buildManagementCard(
          Icons.groups,
          'Mon Groupe',
          '${_myGroupChildren.length} enfants',
          'Voir détails',
          AppColors.errorColor,
          () => setState(() => _currentIndex = 4),
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

  Widget _buildTodaySchedule() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planning du Jour',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 120.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _myActivities.take(3).length,
                itemBuilder: (context, index) {
                  final activity = _myActivities[index];
                  return _buildScheduleCard(activity);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(activity_model.Activity activity) {
    return Container(
      width: 200.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.animatorColor.withOpacity(0.3)),
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
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: activity.status == activity_model.ActivityStatus.inProgress
                      ? AppColors.warningColor
                      : AppColors.infoColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(
                  Icons.event,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
              const Spacer(),
              Text(
                '${_formatTime(activity.startTime)}',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            activity.title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            activity.location,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: activity.status == activity_model.ActivityStatus.inProgress
                  ? AppColors.warningColor.withOpacity(0.1)
                  : AppColors.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              activity.status == activity_model.ActivityStatus.inProgress ? 'En cours' : 'À venir',
              style: TextStyle(
                fontSize: 9.sp,
                color: activity.status == activity_model.ActivityStatus.inProgress
                    ? AppColors.warningColor
                    : AppColors.infoColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions Rapides',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Nouvel Incident',
                    onPressed: _showIncidentDialog,
                    backgroundColor: AppColors.warningColor,
                    height: 40.h,
                    icon: Icons.add,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: 'Appel Présence',
                    onPressed: _showAttendanceDialog,
                    backgroundColor: AppColors.successColor,
                    height: 40.h,
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryPage() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inventaire des Enfants',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              CustomButton(
                text: 'Valider arrivée',
                onPressed: _showCheckInDialog,
                backgroundColor: AppColors.successColor,
                height: 35.h,
                fontSize: 12.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.builder(
              itemCount: _myGroupChildren.length,
              itemBuilder: (context, index) {
                final child = _myGroupChildren[index];
                return _buildInventoryCard(child);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(Child child) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12.h),
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
                  radius: 20.r,
                  backgroundColor: AppColors.animatorColor.withOpacity(0.1),
                  child: Icon(
                    Icons.child_care,
                    color: AppColors.animatorColor,
                    size: 20.sp,
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
                      Text(
                        'Groupe: ${child.groupe} • ${child.age} ans',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.successColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Présent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildInventorySection('Vêtements', [
              'T-shirts: 3/4',
              'Shorts: 2/3',
              'Maillot de bain: 1/1',
              'Pyjama: 1/1',
            ]),
            SizedBox(height: 12.h),
            _buildInventorySection('Effets personnels', [
              'Brosse à dents: ✓',
              'Sac de couchage: ✓',
              'Lampe torche: ✓',
              'Jouets: 3/5',
            ]),
            SizedBox(height: 12.h),
            _buildInventorySection('Médicaments', [
              'Autorisation parentale: ✓',
              'Médicaments: Aucun',
              'Allergies: Aucune',
            ]),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.note, size: 16.sp, color: AppColors.textSecondary),
                SizedBox(width: 6.w),
                Text(
                  'Dernière vérification: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                CustomButton(
                  text: 'Modifier',
                  onPressed: () {},
                  backgroundColor: AppColors.animatorColor,
                  height: 28.h,
                  fontSize: 10.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventorySection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children: items.map((item) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.animatorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResourcesPage() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ressources Pédagogiques',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              CustomButton(
                text: 'Ajouter',
                onPressed: _showAddResourceDialog,
                backgroundColor: AppColors.successColor,
                height: 35.h,
                fontSize: 12.sp,
                icon: Icons.add,
              ),
            ],
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
              itemCount: _resources.length,
              itemBuilder: (context, index) {
                final resource = _resources[index];
                return _buildResourceCard(resource);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          if (resource['type'] == 'song') {
            _showSongDialog(resource);
          } else {
            _showDocumentDialog(resource);
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80.h,
                decoration: BoxDecoration(
                  color: resource['type'] == 'song'
                      ? AppColors.successColor.withOpacity(0.1)
                      : AppColors.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Icon(
                    resource['type'] == 'song' ? Icons.music_note : Icons.description,
                    size: 32.sp,
                    color: resource['type'] == 'song'
                        ? AppColors.successColor
                        : AppColors.infoColor,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                resource['title'],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                resource['category'],
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    resource['type'] == 'song' ? Icons.play_circle : Icons.download,
                    size: 16.sp,
                    color: AppColors.animatorColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    resource['type'] == 'song' ? 'Écouter' : 'Télécharger',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.animatorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentsPage() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestion des Incidents',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              CustomButton(
                text: 'Nouvel incident',
                onPressed: _showIncidentDialog,
                backgroundColor: AppColors.warningColor,
                height: 35.h,
                fontSize: 12.sp,
                icon: Icons.add,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.builder(
              itemCount: _incidents.length,
              itemBuilder: (context, index) {
                final incident = _incidents[index];
                return _buildIncidentCard(incident);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(Map<String, dynamic> incident) {
    final isOpen = incident['status'] == 'open';
    return Card(
      elevation: isOpen ? 6 : 2,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: isOpen
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
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: incident['severity'] == 'high'
                        ? AppColors.errorColor
                        : incident['severity'] == 'medium'
                            ? AppColors.warningColor
                            : AppColors.infoColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    incident['type'] == 'health'
                        ? Icons.healing
                        : incident['type'] == 'behavior'
                            ? Icons.psychology
                            : Icons.report_problem,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident['title'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Enfant: ${incident['child']} • ${incident['time']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOpen)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.warningColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'OUVERT',
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
            Text(
              incident['description'],
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                if (isOpen) ...[
                  CustomButton(
                    text: 'Résoudre',
                    onPressed: () => _resolveIncident(incident),
                    backgroundColor: AppColors.successColor,
                    height: 30.h,
                    fontSize: 11.sp,
                  ),
                  SizedBox(width: 12.w),
                ],
                CustomButton(
                  text: 'Détails',
                  onPressed: () => _showIncidentDetails(incident),
                  backgroundColor: AppColors.infoColor,
                  height: 30.h,
                  fontSize: 11.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupPage() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mon Groupe',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Groupe A • ${_myGroupChildren.length} enfants',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.9,
              ),
              itemCount: _myGroupChildren.length,
              itemBuilder: (context, index) {
                final child = _myGroupChildren[index];
                return _buildGroupChildCard(child);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChildCard(Child child) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.animatorColor.withOpacity(0.1),
                  child: Icon(
                    Icons.child_care,
                    color: AppColors.animatorColor,
                    size: 20.sp,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.successColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              '${child.firstName}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${child.lastName}',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.animatorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '${child.age} ans',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.animatorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.phone, size: 12.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text(
                  '06 XX XX XX XX',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            CustomButton(
              text: 'Voir profil',
              onPressed: () => _showChildProfile(child),
              backgroundColor: AppColors.animatorColor,
              height: 28.h,
              fontSize: 10.sp,
            ),
          ],
        ),
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
      selectedItemColor: AppColors.animatorColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventaire',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note),
          label: 'Ressources',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report),
          label: 'Incidents',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups),
          label: 'Groupe',
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
        groupe: 'A',
        availableMoney: 150.00,
        createdAt: now,
        updatedAt: now,
      ),
      Child(
        id: '2',
        firstName: 'Emma',
        lastName: 'Dubois',
        dateDeNaissance: DateTime(2016, 3, 22),
        groupe: 'A',
        availableMoney: 200.00,
        createdAt: now,
        updatedAt: now,
      ),
      Child(
        id: '3',
        firstName: 'Mathis',
        lastName: 'Bernard',
        dateDeNaissance: DateTime(2015, 11, 8),
        groupe: 'A',
        availableMoney: 175.50,
        createdAt: now,
        updatedAt: now,
      ),
      Child(
        id: '4',
        firstName: 'Chloé',
        lastName: 'Petit',
        dateDeNaissance: DateTime(2016, 7, 12),
        groupe: 'A',
        availableMoney: 125.00,
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
        title: 'Chasse au Trésor',
        description: 'Grande chasse au trésor dans la forêt',
        dates: activity_model.DateTimeRange(
          start: DateTime(now.year, now.month, now.day, 9, 30),
          end: DateTime(now.year, now.month, now.day, 12, 0),
        ),
        location: 'Forêt communale',
        status: activity_model.ActivityStatus.inProgress,
        participants: ['1', '2', '3', '4'],
        createdAt: now,
        updatedAt: now,
      ),
      activity_model.Activity(
        id: '2',
        title: 'Cours de Natation',
        description: 'Cours de natation pour les enfants',
        dates: activity_model.DateTimeRange(
          start: DateTime(now.year, now.month, now.day, 14, 0),
          end: DateTime(now.year, now.month, now.day, 16, 0),
        ),
        location: 'Piscine municipale',
        status: activity_model.ActivityStatus.planned,
        participants: ['2', '4'],
        createdAt: now,
        updatedAt: now,
      ),
      activity_model.Activity(
        id: '3',
        title: 'Atelier Créatif',
        description: 'Atelier de dessin et peinture',
        dates: activity_model.DateTimeRange(
          start: DateTime(now.year, now.month, now.day, 16, 30),
          end: DateTime(now.year, now.month, now.day, 17, 30),
        ),
        location: 'Salle d\'activité',
        status: activity_model.ActivityStatus.planned,
        participants: ['1', '3'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  List<Map<String, dynamic>> _getMockResources() {
    return [
      {
        'id': '1',
        'title': 'Chanson de la colonie',
        'category': 'Chansons',
        'type': 'song',
        'content': 'Paroles de la chanson...',
      },
      {
        'id': '2',
        'title': 'Jeux de piste',
        'category': 'Activités',
        'type': 'document',
        'content': 'Instructions pour les jeux...',
      },
      {
        'id': '3',
        'title': 'Comptines du soir',
        'category': 'Chansons',
        'type': 'song',
        'content': 'Paroles des comptines...',
      },
      {
        'id': '4',
        'title': 'Recettes de cuisine',
        'category': 'Cuisine',
        'type': 'document',
        'content': 'Recettes adaptées aux enfants...',
      },
      {
        'id': '5',
        'title': 'Histoires du soir',
        'category': 'Contes',
        'type': 'document',
        'content': 'Histoires pour le coucher...',
      },
      {
        'id': '6',
        'title': 'Chansons à danser',
        'category': 'Chansons',
        'type': 'song',
        'content': 'Liste des chansons dansantes...',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockIncidents() {
    return [
      {
        'id': '1',
        'title': 'Petite coupure',
        'description': 'L\'enfant s\'est coupé le doigt en jouant',
        'child': 'Lucas Martin',
        'type': 'health',
        'severity': 'low',
        'status': 'closed',
        'time': '10:30',
      },
      {
        'id': '2',
        'title': 'Mal de ventre',
        'description': 'L\'enfant se plaint de maux de ventre après le déjeuner',
        'child': 'Emma Dubois',
        'type': 'health',
        'severity': 'medium',
        'status': 'open',
        'time': '13:45',
      },
      {
        'id': '3',
        'title': 'Dispute avec camarade',
        'description': 'Conflit entre deux enfants lors du jeu',
        'child': 'Mathis Bernard',
        'type': 'behavior',
        'severity': 'medium',
        'status': 'open',
        'time': '15:20',
      },
    ];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showIncidentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvel Incident'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Titre de l\'incident',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Type d\'incident',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'health', child: Text('Santé')),
                DropdownMenuItem(value: 'behavior', child: Text('Comportement')),
                DropdownMenuItem(value: 'material', child: Text('Matériel')),
              ],
              onChanged: (value) {},
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Incident enregistré avec succès')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningColor,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appel de Présence'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _myGroupChildren.length,
            itemBuilder: (context, index) {
              final child = _myGroupChildren[index];
              return CheckboxListTile(
                title: Text('${child.firstName} ${child.lastName}'),
                value: true,
                onChanged: (value) {},
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Présence enregistrée')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showCheckInDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Arrivée'),
        content: const Text('Valider l\'arrivée de tous les enfants du groupe ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Arrivée validée avec succès')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showAddResourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une Ressource'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'song', child: Text('Chanson')),
                DropdownMenuItem(value: 'document', child: Text('Document')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ressource ajoutée avec succès')),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showSongDialog(Map<String, dynamic> song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(song['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note, size: 48.sp, color: AppColors.successColor),
            SizedBox(height: 16.h),
            Text(
              'Catégorie: ${song['category']}',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            const Text(
              'Contenu de la chanson...',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                text: 'Écouter',
                onPressed: () {},
                backgroundColor: AppColors.successColor,
                height: 35.h,
                fontSize: 12.sp,
                icon: Icons.play_arrow,
              ),
              CustomButton(
                text: 'Télécharger',
                onPressed: () {},
                backgroundColor: AppColors.infoColor,
                height: 35.h,
                fontSize: 12.sp,
                icon: Icons.download,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDocumentDialog(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(document['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description, size: 48.sp, color: AppColors.infoColor),
            SizedBox(height: 16.h),
            Text(
              'Catégorie: ${document['category']}',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            const Text(
              'Contenu du document...',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'Télécharger',
            onPressed: () {},
            backgroundColor: AppColors.infoColor,
            height: 35.h,
            fontSize: 12.sp,
            icon: Icons.download,
          ),
        ],
      ),
    );
  }

  void _resolveIncident(Map<String, dynamic> incident) {
    setState(() {
      incident['status'] = 'closed';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incident résolu avec succès')),
    );
  }

  void _showIncidentDetails(Map<String, dynamic> incident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(incident['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enfant: ${incident['child']}'),
            Text('Heure: ${incident['time']}'),
            Text('Type: ${incident['type']}'),
            Text('Gravité: ${incident['severity']}'),
            Text('Statut: ${incident['status']}'),
            SizedBox(height: 12.h),
            Text('Description: ${incident['description']}'),
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

  void _showChildProfile(Child child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${child.firstName} ${child.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Âge: ${child.age} ans'),
            Text('Groupe: ${child.groupe}'),
            Text('Solde: €${child.availableMoney.toStringAsFixed(2)}'),
            SizedBox(height: 12.h),
            const Text('Notes: Enfant très sociable et participatif'),
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