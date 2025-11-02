import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user.dart';
import '../../models/activity.dart' as activity_model;
import '../../models/user_type.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class ActivitiesManagementScreen extends StatefulWidget {
  final User user;

  const ActivitiesManagementScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ActivitiesManagementScreen> createState() => _ActivitiesManagementScreenState();
}

class _ActivitiesManagementScreenState extends State<ActivitiesManagementScreen> {
  bool _isLoading = false;
  List<activity_model.Activity> _activities = [];
  List<activity_model.Activity> _filteredActivities = [];
  String _searchQuery = '';
  activity_model.ActivityStatus? _selectedStatus;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      final activities = _getMockActivities();
      setState(() {
        _activities = activities;
        _filteredActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterActivities() {
    setState(() {
      _filteredActivities = _activities.where((activity) {
        final matchesSearch = activity.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            activity.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            activity.description.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = _selectedStatus == null || activity.status == _selectedStatus;

        bool matchesDate = true;
        if (_selectedDateRange != null) {
          matchesDate = !activity.startTime.isBefore(_selectedDateRange!.start) &&
                       !activity.startTime.isAfter(_selectedDateRange!.end);
        }

        return matchesSearch && matchesStatus && matchesDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion des Activités',
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: AppColors.directorColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddActivityDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActivities,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchAndFilter(),
                _buildStatsSection(),
                Expanded(child: _buildActivitiesList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddActivityDialog,
        backgroundColor: AppColors.directorColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une activité...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterActivities();
            },
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: const Text('Filtrer par date'),
                  selected: _selectedDateRange != null,
                  onSelected: (selected) async {
                    if (selected) {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (range != null) {
                        setState(() {
                          _selectedDateRange = range;
                          _filterActivities();
                        });
                      }
                    } else {
                      setState(() {
                        _selectedDateRange = null;
                        _filterActivities();
                      });
                    }
                  },
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  selectedColor: AppColors.directorColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _selectedDateRange != null
                        ? AppColors.directorColor
                        : AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: DropdownButtonFormField<activity_model.ActivityStatus>(
                  decoration: const InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: _selectedStatus,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tous'),
                    ),
                    ...activity_model.ActivityStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusDisplayName(status)),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                      _filterActivities();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              '${_activities.length}',
              Icons.event,
              AppColors.infoColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'En cours',
              '${_activities.where((a) => a.status == activity_model.ActivityStatus.inProgress).length}',
              Icons.play_circle,
              AppColors.warningColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Terminées',
              '${_activities.where((a) => a.status == activity_model.ActivityStatus.completed).length}',
              Icons.check_circle,
              AppColors.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList() {
    return _filteredActivities.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48.sp,
                  color: AppColors.textHint,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Aucune activité trouvée',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _filteredActivities.length,
            itemBuilder: (context, index) {
              final activity = _filteredActivities[index];
              return _buildActivityCard(activity);
            },
          );
  }

  Widget _buildActivityCard(activity_model.Activity activity) {
    final statusColor = _getStatusColor(activity.status);
    return Card(
      elevation: 4,
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
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.event,
                    color: statusColor,
                    size: 24.sp,
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
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              _getStatusDisplayName(activity.status),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (activity.participants.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.infoColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                '${activity.participants.length} participants',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.infoColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditActivityDialog(activity);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(activity);
                        break;
                      case 'duplicate':
                        _duplicateActivity(activity);
                        break;
                      case 'view':
                        _showActivityDetails(activity);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 16),
                          SizedBox(width: 8),
                          Text('Voir détails'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 16),
                          SizedBox(width: 8),
                          Text('Dupliquer'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              activity.description,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'Lieu',
                    activity.location,
                    Icons.location_on,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    'Durée',
                    activity.duration.inHours > 0
                        ? '${activity.duration.inHours}h${activity.duration.inMinutes % 60}min'
                        : '${activity.duration.inMinutes}min',
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              activity.formattedDateRange,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Participants',
                    onPressed: () => _showParticipantsDialog(activity),
                    backgroundColor: AppColors.infoColor,
                    height: 35.h,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: 'Animateurs',
                    onPressed: () => _showAnimatorsDialog(activity),
                    backgroundColor: AppColors.animatorColor,
                    height: 35.h,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: activity.status == activity_model.ActivityStatus.planned
                        ? 'Démarrer'
                        : activity.status == activity_model.ActivityStatus.inProgress
                            ? 'Terminer'
                            : 'Voir rapport',
                    onPressed: () => _handleActivityAction(activity),
                    backgroundColor: activity.status == activity_model.ActivityStatus.completed
                        ? AppColors.successColor
                        : statusColor,
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

  Widget _buildInfoRow(String label, String value, IconData icon, [Color? iconColor]) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: iconColor ?? AppColors.textSecondary),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getStatusDisplayName(activity_model.ActivityStatus status) {
    switch (status) {
      case activity_model.ActivityStatus.planned:
        return 'Planifiée';
      case activity_model.ActivityStatus.inProgress:
        return 'En cours';
      case activity_model.ActivityStatus.completed:
        return 'Terminée';
      case activity_model.ActivityStatus.cancelled:
        return 'Annulée';
      default:
        return 'Inconnue';
    }
  }

  Color _getStatusColor(activity_model.ActivityStatus status) {
    switch (status) {
      case activity_model.ActivityStatus.planned:
        return AppColors.infoColor;
      case activity_model.ActivityStatus.inProgress:
        return AppColors.warningColor;
      case activity_model.ActivityStatus.completed:
        return AppColors.successColor;
      case activity_model.ActivityStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddActivityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une activité'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16.h),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Lieu',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Date de début',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Heure de début',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                const SnackBar(content: Text('Activité ajoutée avec succès')),
              );
              _loadActivities();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.directorColor,
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditActivityDialog(activity_model.Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${activity.title}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: activity.title),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: activity.description),
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: activity.location),
              ),
            ],
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
                const SnackBar(content: Text('Activité modifiée avec succès')),
              );
              _loadActivities();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.directorColor,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(activity_model.Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation de suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'activité "${activity.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activité supprimée avec succès')),
              );
              _loadActivities();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _duplicateActivity(activity_model.Activity activity) {
    setState(() {
      // Create a copy of the activity with a new ID
      final newActivity = activity_model.Activity(
        id: 'new-${DateTime.now().millisecondsSinceEpoch}',
        title: '${activity.title} (copie)',
        description: activity.description,
        dates: activity.dates,
        location: activity.location,
        groupe: activity.groupe,
        participants: [],
        animatorIds: activity.animatorIds,
        status: activity_model.ActivityStatus.planned,
        imageUrl: activity.imageUrl,
        requiredMaterials: activity.requiredMaterials,
        metadata: activity.metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _activities.insert(0, newActivity);
      _filterActivities();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activité dupliquée avec succès')),
    );
  }

  void _showActivityDetails(activity_model.Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${activity.description}'),
              Text('Lieu: ${activity.location}'),
              Text('Date: ${activity.formattedDateRange}'),
              Text('Statut: ${_getStatusDisplayName(activity.status)}'),
              Text('Participants: ${activity.participants.length}'),
              Text('Animateurs: ${activity.animatorIds.length}'),
              if (activity.requiredMaterials.isNotEmpty) ...[
                SizedBox(height: 16.h),
                const Text('Matériel requis:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...activity.requiredMaterials.map((material) => Text('• $material')),
              ],
            ],
          ),
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

  void _showParticipantsDialog(activity_model.Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Participants - ${activity.title}'),
        content: SizedBox(
          width: double.maxFinite,
          child: activity.participants.isEmpty
              ? const Text('Aucun participant inscrit')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: activity.participants.map((participantId) {
                    return ListTile(
                      title: Text('Enfant $participantId'),
                      subtitle: Text('Groupe A'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Participant retiré')),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajout de participants - En cours de développement')),
              );
            },
            child: const Text('Ajouter des participants'),
          ),
        ],
      ),
    );
  }

  void _showAnimatorsDialog(activity_model.Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Animateurs - ${activity.title}'),
        content: SizedBox(
          width: double.maxFinite,
          child: activity.animatorIds.isEmpty
              ? const Text('Aucun animateur assigné')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: activity.animatorIds.map((animatorId) {
                    return ListTile(
                      title: Text('Animateur $animatorId'),
                      subtitle: Text('Principal'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Animateur retiré')),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Assignation d\'animateurs - En cours de développement')),
              );
            },
            child: const Text('Assigner des animateurs'),
          ),
        ],
      ),
    );
  }

  void _handleActivityAction(activity_model.Activity activity) {
    switch (activity.status) {
      case activity_model.ActivityStatus.planned:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Activité "${activity.title}" démarrée - En cours de développement')),
        );
        break;
      case activity_model.ActivityStatus.inProgress:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Activité "${activity.title}" terminée - En cours de développement')),
        );
        break;
      case activity_model.ActivityStatus.completed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rapport de l\'activité - En cours de développement')),
        );
        break;
      case activity_model.ActivityStatus.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Activité annulée - Contactez l\'administration')),
        );
        break;
    }
  }

  List<activity_model.Activity> _getMockActivities() {
    final now = DateTime.now();
    return [
      activity_model.Activity(
        id: '1',
        title: 'Chasse au Trésor',
        description: 'Grande chasse au trésor dans la forêt avec énigmes et défis',
        dates: activity_model.DateTimeRange(
          start: now.add(const Duration(days: 1, hours: 9)),
          end: now.add(const Duration(days: 1, hours: 12)),
        ),
        location: 'Forêt communale',
        status: activity_model.ActivityStatus.planned,
        participants: ['1', '2', '3'],
        animatorIds: ['1'],
        requiredMaterials: ['Cartes', 'Boussoles', 'Trésor', 'Foulards'],
        createdAt: now,
        updatedAt: now,
      ),
      activity_model.Activity(
        id: '2',
        title: 'Cours de Natation',
        description: 'Cours de natation pour tous les niveaux avec moniteurs qualifiés',
        dates: activity_model.DateTimeRange(
          start: now.add(const Duration(days: 1, hours: 14)),
          end: now.add(const Duration(days: 1, hours: 16)),
        ),
        location: 'Piscine municipale',
        status: activity_model.ActivityStatus.inProgress,
        participants: ['2', '4'],
        animatorIds: ['2'],
        requiredMaterials: ['Maillots de bain', 'Touques', 'Lunettes de natation'],
        createdAt: now,
        updatedAt: now,
      ),
      activity_model.Activity(
        id: '3',
        title: 'Théâtre',
        description: 'Atelier théâtre avec présentation d\'une pièce',
        dates: activity_model.DateTimeRange(
          start: now.add(const Duration(days: 2, hours: 10)),
          end: now.add(const Duration(days: 2, hours: 12)),
        ),
        location: 'Salle polyvalente',
        status: activity_model.ActivityStatus.completed,
        participants: ['1', '3', '5'],
        animatorIds: ['1', '2'],
        requiredMaterials: ['Costumes', 'Décor', 'Scripts', 'Maquillage'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}