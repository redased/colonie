import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class RegistersScreen extends StatefulWidget {
  final User user;

  const RegistersScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<RegistersScreen> createState() => _RegistersScreenState();
}

class _RegistersScreenState extends State<RegistersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registres',
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: AppColors.directorColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registres de la Colonie',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Consultez et gérez tous les registres obligatoires',
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
                childAspectRatio: 1.0,
                children: [
                  _buildRegisterCard(
                    Icons.people,
                    'Registre de Présence',
                    'Suivi des présences quotidiennes',
                    AppColors.infoColor,
                    () => _showPresenceRegister(),
                  ),
                  _buildRegisterCard(
                    Icons.healing,
                    'Registre Médical',
                    'Soins et traitements administrés',
                    AppColors.errorColor,
                    () => _showMedicalRegister(),
                  ),
                  _buildRegisterCard(
                    Icons.restaurant,
                    'Registre Alimentaire',
                    'Repas et régimes spéciaux',
                    AppColors.successColor,
                    () => _showFoodRegister(),
                  ),
                  _buildRegisterCard(
                    Icons.local_shipping,
                    'Registre de Transport',
                    'Déplacements et véhicules',
                    AppColors.warningColor,
                    () => _showTransportRegister(),
                  ),
                  _buildRegisterCard(
                    Icons.security,
                    'Registre de Sécurité',
                    'Incidents et mesures de sécurité',
                    AppColors.animatorColor,
                    () => _showSafetyRegister(),
                  ),
                  _buildRegisterCard(
                    Icons.description,
                    'Registre Administratif',
                    'Documents administratifs',
                    AppColors.accountantColor,
                    () => _showAdminRegister(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterCard(
    IconData icon,
    String title,
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  size: 40.sp,
                  color: color,
                ),
              ),
              SizedBox(height: 16.h),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPresenceRegister() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registre de Présence'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const ListTile(
                      title: Text('Lundi 15 Juillet 2024'),
                      subtitle: Text('Présents: 28/30 • Absents: 2'),
                      trailing: Icon(Icons.check_circle, color: Colors.green),
                    ),
                    const ListTile(
                      title: Text('Mardi 16 Juillet 2024'),
                      subtitle: Text('Présents: 30/30 • Absents: 0'),
                      trailing: Icon(Icons.check_circle, color: Colors.green),
                    ),
                    const ListTile(
                      title: Text('Mercredi 17 Juillet 2024'),
                      subtitle: Text('Présents: 29/30 • Absents: 1 (Maladie)'),
                      trailing: Icon(Icons.healing, color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: 'Exporter',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export du registre de présence...')),
              );
            },
            backgroundColor: AppColors.infoColor,
          ),
          CustomButton(
            text: 'Fermer',
            onPressed: () => Navigator.pop(context),
            backgroundColor: AppColors.directorColor,
          ),
        ],
      ),
    );
  }

  void _showMedicalRegister() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registre Médical'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: ListView(
            children: [
              Card(
                color: Colors.red.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.healing, color: Colors.red),
                  title: const Text('Petite coupure - Lucas Martin'),
                  subtitle: const Text('15/07/2024 10:30 - Désinfection et pansement'),
                  trailing: const Text('Soigné', style: TextStyle(color: Colors.green)),
                ),
              ),
              Card(
                color: Colors.orange.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.sick, color: Colors.orange),
                  title: const Text('Mal de ventre - Emma Dubois'),
                  subtitle: const Text('15/07/2024 14:15 - Repos et surveillance'),
                  trailing: const Text('En observation', style: TextStyle(color: Colors.orange)),
                ),
              ),
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.medication, color: Colors.blue),
                  title: const Text('Médicament - Mathis Bernard'),
                  subtitle: const Text('15/07/2024 12:00 - Antibiotique sur ordonnance'),
                  trailing: const Text('Administré', style: TextStyle(color: Colors.green)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: 'Ajouter un soin',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Formulaire de soin...')),
              );
            },
            backgroundColor: AppColors.errorColor,
          ),
          CustomButton(
            text: 'Fermer',
            onPressed: () => Navigator.pop(context),
            backgroundColor: AppColors.directorColor,
          ),
        ],
      ),
    );
  }

  void _showFoodRegister() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registre Alimentaire'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: ListView(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.free_breakfast, color: Colors.brown),
                  title: const Text('Petit-déjeuner - 15/07/2024'),
                  subtitle: const Text('30 enfants • Régimes: 1 végétarien'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lunch_dining, color: Colors.orange),
                  title: const Text('Déjeuner - 15/07/2024'),
                  subtitle: const Text('29 enfants • Allergies: 2 arachides, 1 gluten'),
                  trailing: const Icon(Icons.warning, color: Colors.orange),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.local_dining, color: Colors.purple),
                  title: const Text('Goûter - 15/07/2024'),
                  subtitle: const Text('30 enfants • Portions: 30'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: 'Menu de la semaine',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Affichage du menu...')),
              );
            },
            backgroundColor: AppColors.successColor,
          ),
          CustomButton(
            text: 'Fermer',
            onPressed: () => Navigator.pop(context),
            backgroundColor: AppColors.directorColor,
          ),
        ],
      ),
    );
  }

  void _showTransportRegister() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registre de Transport'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: ListView(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_bus, color: Colors.blue),
                  title: const Text('Bus 1 - Forêt communale'),
                  subtitle: const Text('15/07/2024 09:00 • 30 enfants • Conducteur: Pierre'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.local_taxi, color: Colors.orange),
                  title: const Text('Van - Piscine municipale'),
                  subtitle: const Text('15/07/2024 13:30 • 15 enfants • Conducteur: Marie'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.car_rental, color: Colors.green),
                  title: const Text('Voiture - Urgence médicale'),
                  subtitle: const Text('15/07/2024 14:15 • 1 enfant (Emma)'),
                  trailing: const Icon(Icons.priority_high, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: 'Ajouter un trajet',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Formulaire de trajet...')),
              );
            },
            backgroundColor: AppColors.warningColor,
          ),
          CustomButton(
            text: 'Fermer',
            onPressed: () => Navigator.pop(context),
            backgroundColor: AppColors.directorColor,
          ),
        ],
      ),
    );
  }

  void _showSafetyRegister() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registre de Sécurité'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: ListView(
            children: [
              Card(
                color: Colors.red.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: const Text('Chute - Terrain de sport'),
                  subtitle: const Text('15/07/2024 10:45 - Lucas Martin - Genou éraflé'),
                  trailing: const Text('Traitement: OK', style: TextStyle(color: Colors.green)),
                ),
              ),
              Card(
                color: Colors.orange.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.whatshot, color: Colors.orange),
                  title: const Text('Vérification extincteurs'),
                  subtitle: const Text('15/07/2024 08:00 - Tous les extincteurs vérifiés'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.group, color: Colors.blue),
                  title: const Text('Exercice d\'évacuation'),
                  subtitle: const Text('15/07/2024 11:00 - Évacuation réussie en 3 minutes'),
                  trailing: const Icon(Icons.verified, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: 'Signaler un incident',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Formulaire d\'incident...')),
              );
            },
            backgroundColor: AppColors.animatorColor,
          ),
          CustomButton(
            text: 'Fermer',
            onPressed: () => Navigator.pop(context),
            backgroundColor: AppColors.directorColor,
          ),
        ],
      ),
    );
  }

  void _showAdminRegister() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registre Administratif'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: ListView(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.description, color: Colors.blue),
                  title: const Text('Autorisations parentales'),
                  subtitle: const Text('30/30 reçues • Validées'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.purple),
                  title: const Text('Photos autorisées'),
                  subtitle: const Text('28/30 autorisations • 2 refus'),
                  trailing: const Text('OK', style: TextStyle(color: Colors.green)),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.payment, color: Colors.green),
                  title: const Text('Paiements inscription'),
                  subtitle: const Text('28/30 payés • 2 en attente'),
                  trailing: const Icon(Icons.pending, color: Colors.orange),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.contact_mail, color: Colors.orange),
                  title: const Text('Contacts d\'urgence'),
                  subtitle: const Text('30/30 contacts vérifiés'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: 'Exporter tous les registres',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export en cours...')),
              );
            },
            backgroundColor: AppColors.accountantColor,
          ),
          CustomButton(
            text: 'Fermer',
            onPressed: () => Navigator.pop(context),
            backgroundColor: AppColors.directorColor,
          ),
        ],
      ),
    );
  }
}