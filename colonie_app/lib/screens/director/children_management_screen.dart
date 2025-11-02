import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user.dart';
import '../../models/child.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class ChildrenManagementScreen extends StatefulWidget {
  final User user;

  const ChildrenManagementScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChildrenManagementScreen> createState() => _ChildrenManagementScreenState();
}

class _ChildrenManagementScreenState extends State<ChildrenManagementScreen> {
  bool _isLoading = false;
  List<Child> _children = [];
  List<Child> _filteredChildren = [];
  String _searchQuery = '';
  String _selectedGroup = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      final children = _getMockChildren();
      setState(() {
        _children = children;
        _filteredChildren = children;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterChildren() {
    setState(() {
      _filteredChildren = _children.where((child) {
        final matchesSearch = child.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            child.lastName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesGroup = _selectedGroup == 'Tous' || child.groupe == _selectedGroup;
        return matchesSearch && matchesGroup;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion des Enfants',
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
            onPressed: _showAddChildDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChildren,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchAndFilter(),
                _buildStatsSection(),
                Expanded(child: _buildChildrenList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddChildDialog,
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
              hintText: 'Rechercher un enfant...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterChildren();
            },
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                'Filtrer par groupe:',
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
                    children: ['Tous', 'group-1', 'group-2', 'group-3'].map((group) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: FilterChip(
                          label: Text(group),
                          selected: _selectedGroup == group,
                          onSelected: (selected) {
                            setState(() {
                              _selectedGroup = group;
                              _filterChildren();
                            });
                          },
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          selectedColor: AppColors.directorColor.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _selectedGroup == group
                                ? AppColors.directorColor
                                : AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      );
                    }).toList(),
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
              '${_children.length}',
              Icons.child_care,
              AppColors.infoColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Group-1',
              '${_children.where((c) => c.groupe == 'group-1').length}',
              Icons.group,
              AppColors.successColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Group-2',
              '${_children.where((c) => c.groupe == 'group-2').length}',
              Icons.group,
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

  Widget _buildChildrenList() {
    return _filteredChildren.isEmpty
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
                  'Aucun enfant trouvé',
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
            itemCount: _filteredChildren.length,
            itemBuilder: (context, index) {
              final child = _filteredChildren[index];
              return _buildChildCard(child);
            },
          );
  }

  Widget _buildChildCard(Child child) {
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
                  backgroundColor: AppColors.directorColor.withOpacity(0.1),
                  child: Icon(
                    Icons.child_care,
                    color: AppColors.directorColor,
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
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.directorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '${child.age} ans',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.directorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.infoColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              child.groupe ?? 'Non assigné',
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
                        _showEditChildDialog(child);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(child);
                        break;
                      case 'view':
                        _showChildDetails(child);
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
                    'Date de naissance',
                    '${child.dateDeNaissance.day}/${child.dateDeNaissance.month}/${child.dateDeNaissance.year}',
                    Icons.cake,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    'Solde disponible',
                    '€${child.availableMoney.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Voir planning',
                    onPressed: () => _showChildPlanning(child),
                    backgroundColor: AppColors.infoColor,
                    height: 35.h,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: 'Gérer solde',
                    onPressed: () => _showBalanceDialog(child),
                    backgroundColor: AppColors.successColor,
                    height: 35.h,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: 'Documents',
                    onPressed: () => _showDocumentsDialog(child),
                    backgroundColor: AppColors.warningColor,
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
          ),
        ),
      ],
    );
  }

  void _showAddChildDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un enfant'),
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
                  labelText: 'Date de naissance (JJ/MM/AAAA)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Groupe',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'group-1', child: Text('Groupe 1')),
                  DropdownMenuItem(value: 'group-2', child: Text('Groupe 2')),
                  DropdownMenuItem(value: 'group-3', child: Text('Groupe 3')),
                ],
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
                const SnackBar(content: Text('Enfant ajouté avec succès')),
              );
              _loadChildren();
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

  void _showEditChildDialog(Child child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${child.firstName} ${child.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: child.firstName),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: child.lastName),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Groupe',
                border: OutlineInputBorder(),
              ),
              value: child.groupe,
              items: const [
                DropdownMenuItem(value: 'group-1', child: Text('Groupe 1')),
                DropdownMenuItem(value: 'group-2', child: Text('Groupe 2')),
                DropdownMenuItem(value: 'group-3', child: Text('Groupe 3')),
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
                const SnackBar(content: Text('Modifications enregistrées')),
              );
              _loadChildren();
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

  void _showDeleteConfirmation(Child child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation de suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${child.firstName} ${child.lastName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enfant supprimé avec succès')),
              );
              _loadChildren();
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

  void _showChildDetails(Child child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${child.firstName} ${child.lastName}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Âge: ${child.age} ans'),
              Text('Date de naissance: ${child.dateDeNaissance.day}/${child.dateDeNaissance.month}/${child.dateDeNaissance.year}'),
              Text('Groupe: ${child.groupe ?? 'Non assigné'}'),
              Text('Solde disponible: €${child.availableMoney.toStringAsFixed(2)}'),
              SizedBox(height: 16.h),
              const Text('Informations médicales:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Aucune information médicale enregistrée'),
              SizedBox(height: 16.h),
              const Text('Contacts d\'urgence:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Père: 06 XX XX XX XX'),
              const Text('Mère: 06 XX XX XX XX'),
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

  void _showChildPlanning(Child child) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Planning de ${child.firstName} - En cours de développement')),
    );
  }

  void _showBalanceDialog(Child child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gérer le solde de ${child.firstName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Solde actuel: €${child.availableMoney.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Montant à ajouter (€)',
                border: OutlineInputBorder(),
                prefixText: '€',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Motif',
                border: OutlineInputBorder(),
              ),
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
                const SnackBar(content: Text('Solde mis à jour avec succès')),
              );
              _loadChildren();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showDocumentsDialog(Child child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Documents de ${child.firstName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.description, color: AppColors.infoColor),
              title: Text('Autorisation parentale'),
              subtitle: Text('Signée et valide'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
            const ListTile(
              leading: Icon(Icons.medical_services, color: AppColors.warningColor),
              title: Text('Fiche médicale'),
              subtitle: Text('À compléter'),
              trailing: Icon(Icons.warning, color: AppColors.warningColor),
            ),
            const ListTile(
              leading: Icon(Icons.photo, color: AppColors.successColor),
              title: Text('Photo d\'identité'),
              subtitle: Text('Validée'),
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
        groupe: 'group-1',
        availableMoney: 200.00,
        createdAt: now,
        updatedAt: now,
      ),
      Child(
        id: '3',
        firstName: 'Mathis',
        lastName: 'Bernard',
        dateDeNaissance: DateTime(2015, 11, 8),
        groupe: 'group-2',
        availableMoney: 175.50,
        createdAt: now,
        updatedAt: now,
      ),
      Child(
        id: '4',
        firstName: 'Chloé',
        lastName: 'Petit',
        dateDeNaissance: DateTime(2016, 7, 12),
        groupe: 'group-2',
        availableMoney: 125.00,
        createdAt: now,
        updatedAt: now,
      ),
      Child(
        id: '5',
        firstName: 'Louis',
        lastName: 'Rousseau',
        dateDeNaissance: DateTime(2015, 9, 30),
        groupe: 'group-3',
        availableMoney: 300.00,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}