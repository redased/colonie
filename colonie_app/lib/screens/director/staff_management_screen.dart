import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user.dart';
import '../../models/user_type.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class StaffManagementScreen extends StatefulWidget {
  final User user;

  const StaffManagementScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  bool _isLoading = false;
  List<User> _staff = [];
  List<User> _filteredStaff = [];
  String _searchQuery = '';
  UserType? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      final staff = _getMockStaff();
      setState(() {
        _staff = staff;
        _filteredStaff = staff;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterStaff() {
    setState(() {
      _filteredStaff = _staff.where((person) {
        final matchesSearch = person.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            person.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            person.email.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesRole = _selectedRole == null || person.userType == _selectedRole;
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion du Personnel',
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
            onPressed: _showAddStaffDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStaff,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchAndFilter(),
                _buildStatsSection(),
                Expanded(child: _buildStaffList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStaffDialog,
        backgroundColor: AppColors.directorColor,
        child: const Icon(Icons.person_add),
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
              hintText: 'Rechercher un membre du personnel...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterStaff();
            },
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                'Filtrer par rôle:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Tous'),
                        selected: _selectedRole == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedRole = selected ? null : _selectedRole;
                            _filterStaff();
                          });
                        },
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        selectedColor: AppColors.directorColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _selectedRole == null
                              ? AppColors.directorColor
                              : AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ...UserType.values.where((type) => type != UserType.parent).map((role) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: FilterChip(
                            label: Text(_getRoleDisplayName(role)),
                            selected: _selectedRole == role,
                            onSelected: (selected) {
                              setState(() {
                                _selectedRole = selected ? role : null;
                                _filterStaff();
                              });
                            },
                            backgroundColor: Colors.grey.withOpacity(0.1),
                            selectedColor: AppColors.directorColor.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: _selectedRole == role
                                  ? AppColors.directorColor
                                  : AppColors.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
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
              '${_staff.length}',
              Icons.people,
              AppColors.infoColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Animateurs',
              '${_staff.where((s) => s.userType == UserType.animator).length}',
              Icons.sports,
              AppColors.successColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Administratif',
              '${_staff.where((s) => s.userType == UserType.accountant).length}',
              Icons.business_center,
              AppColors.warningColor,
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

  Widget _buildStaffList() {
    return _filteredStaff.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48.sp,
                  color: AppColors.textHint,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Aucun membre du personnel trouvé',
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
            itemCount: _filteredStaff.length,
            itemBuilder: (context, index) {
              final staffMember = _filteredStaff[index];
              return _buildStaffCard(staffMember);
            },
          );
  }

  Widget _buildStaffCard(User staffMember) {
    final roleColor = _getRoleColor(staffMember.userType);
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
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: roleColor.withOpacity(0.1),
                  child: Icon(
                    _getRoleIcon(staffMember.userType),
                    color: roleColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${staffMember.firstName} ${staffMember.lastName}',
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
                              color: roleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              _getRoleDisplayName(staffMember.userType),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: roleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (staffMember.isActive != false)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'Actif',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.green,
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
                        _showEditStaffDialog(staffMember);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(staffMember);
                        break;
                      case 'toggle_status':
                        _toggleStaffStatus(staffMember);
                        break;
                      case 'view':
                        _showStaffDetails(staffMember);
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
                      value: 'toggle_status',
                      child: Row(
                        children: [
                          Icon(Icons.block, size: 16),
                          SizedBox(width: 8),
                          Text('Désactiver'),
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
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'Email',
                    staffMember.email,
                    Icons.email,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    'Téléphone',
                    staffMember.phoneNumber ?? 'Non renseigné',
                    Icons.phone,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Planning',
                    onPressed: () => _showStaffPlanning(staffMember),
                    backgroundColor: AppColors.infoColor,
                    height: 35.h,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: 'Documents',
                    onPressed: () => _showDocumentsDialog(staffMember),
                    backgroundColor: AppColors.warningColor,
                    height: 35.h,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: 'Message',
                    onPressed: () => _showMessageDialog(staffMember),
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

  String _getRoleDisplayName(UserType userType) {
    switch (userType) {
      case UserType.director:
        return 'Directeur';
      case UserType.animator:
        return 'Animateur';
      case UserType.accountant:
        return 'Comptable';
      case UserType.parent:
        return 'Parent';
      default:
        return 'Inconnu';
    }
  }

  IconData _getRoleIcon(UserType userType) {
    switch (userType) {
      case UserType.director:
        return Icons.admin_panel_settings;
      case UserType.animator:
        return Icons.sports;
      case UserType.accountant:
        return Icons.account_balance;
      case UserType.parent:
        return Icons.family_restroom;
      default:
        return Icons.person;
    }
  }

  Color _getRoleColor(UserType userType) {
    switch (userType) {
      case UserType.director:
        return AppColors.directorColor;
      case UserType.animator:
        return AppColors.animatorColor;
      case UserType.accountant:
        return AppColors.accountantColor;
      case UserType.parent:
        return AppColors.parentColor;
      default:
        return Colors.grey;
    }
  }

  void _showAddStaffDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un membre du personnel'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixText: '@',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<UserType>(
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  border: OutlineInputBorder(),
                ),
                items: UserType.values.where((type) => type != UserType.parent).map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(_getRoleDisplayName(role)),
                  );
                }).toList(),
                onChanged: (value) {},
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
                const SnackBar(content: Text('Membre du personnel ajouté avec succès')),
              );
              _loadStaff();
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

  void _showEditStaffDialog(User staffMember) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${staffMember.firstName} ${staffMember.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: staffMember.firstName),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: staffMember.lastName),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: staffMember.email),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: staffMember.phoneNumber),
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
                const SnackBar(content: Text('Modifications enregistrées')),
              );
              _loadStaff();
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

  void _showDeleteConfirmation(User staffMember) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation de suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${staffMember.firstName} ${staffMember.lastName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membre du personnel supprimé avec succès')),
              );
              _loadStaff();
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

  void _toggleStaffStatus(User staffMember) {
    setState(() {
      // Toggle active status (this would update the backend in a real app)
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Statut de ${staffMember.firstName} modifié')),
    );
  }

  void _showStaffDetails(User staffMember) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${staffMember.firstName} ${staffMember.lastName}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rôle: ${_getRoleDisplayName(staffMember.userType)}'),
              Text('Email: ${staffMember.email}'),
              Text('Téléphone: ${staffMember.phoneNumber ?? 'Non renseigné'}'),
              Text('Statut: ${staffMember.isActive != false ? 'Actif' : 'Inactif'}'),
              SizedBox(height: 16.h),
              const Text('Informations additionnelles:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Date d\'embauche: 01/01/2024'),
              const Text('Diplômes: BAFA, PSC1'),
              const Text('Spécialités: Sport, Art'),
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

  void _showStaffPlanning(User staffMember) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Planning de ${staffMember.firstName} - En cours de développement')),
    );
  }

  void _showDocumentsDialog(User staffMember) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Documents de ${staffMember.firstName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.description, color: AppColors.infoColor),
              title: Text('Contrat de travail'),
              subtitle: Text('Signé et valide'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
            const ListTile(
              leading: Icon(Icons.card_membership, color: AppColors.warningColor),
              title: Text('BAFA'),
              subtitle: Text('En cours de validation'),
              trailing: Icon(Icons.hourglass_empty, color: AppColors.warningColor),
            ),
            const ListTile(
              leading: Icon(Icons.local_hospital, color: AppColors.successColor),
              title: Text('Certificat médical'),
              subtitle: Text('Valide jusqu\'au 31/12/2024'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
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
                const SnackBar(content: Text('Téléchargement des documents...')),
              );
            },
            child: const Text('Télécharger tout'),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(User staffMember) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message pour ${staffMember.firstName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Sujet',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
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
                SnackBar(content: Text('Message envoyé à ${staffMember.firstName}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
            ),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  List<User> _getMockStaff() {
    final now = DateTime.now();
    return [
      User(
        id: '1',
        firstName: 'Pierre',
        lastName: 'Martin',
        userType: UserType.animator,
        email: 'pierre.martin@colonie.com',
        phoneNumber: '06 12 34 56 78',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      User(
        id: '2',
        firstName: 'Marie',
        lastName: 'Dubois',
        userType: UserType.animator,
        email: 'marie.dubois@colonie.com',
        phoneNumber: '06 23 45 67 89',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      User(
        id: '3',
        firstName: 'Jean',
        lastName: 'Bernard',
        userType: UserType.accountant,
        email: 'jean.bernard@colonie.com',
        phoneNumber: '06 34 56 78 90',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      User(
        id: '4',
        firstName: 'Sophie',
        lastName: 'Petit',
        userType: UserType.animator,
        email: 'sophie.petit@colonie.com',
        phoneNumber: '06 45 67 89 01',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}