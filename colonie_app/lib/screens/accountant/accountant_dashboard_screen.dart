import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class AccountantDashboardScreen extends StatefulWidget {
  final User user;

  const AccountantDashboardScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<AccountantDashboardScreen> createState() => _AccountantDashboardScreenState();
}

class _AccountantDashboardScreenState extends State<AccountantDashboardScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;
  double _totalRevenue = 0.0;
  double _totalExpenses = 0.0;
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _totalRevenue = 1542050.00;
        _totalExpenses = 892575.00;
        _balance = _totalRevenue - _totalExpenses;
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
          'Tableau de Bord Financier',
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: AppColors.accountantColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFinancialData,
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
          _buildFinancialOverview(),
          SizedBox(height: 24.h),
          _buildQuickActions(),
          SizedBox(height: 24.h),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.accountantColor,
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          colors: [AppColors.accountantColor, AppColors.accountantColor.withOpacity(0.8)],
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
            'Gestion Financière de la Colonie',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildFinanceCard('Solde Actuel', '${_balance.toStringAsFixed(2)} DA',
                    Icons.trending_up),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildFinanceCard('Mois', '${DateTime.now().month}/${DateTime.now().year}',
                    Icons.calendar_today),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String title, String value, IconData icon) {
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
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview() {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Recettes',
            '${_totalRevenue.toStringAsFixed(2)} DA',
            AppColors.successColor,
            Icons.arrow_upward,
            '+12.5%',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildOverviewCard(
            'Dépenses',
            '${_totalExpenses.toStringAsFixed(2)} DA',
            AppColors.errorColor,
            Icons.arrow_downward,
            '+8.3%',
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String amount, Color color, IconData icon, String percentage) {
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
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(icon, color: color, size: 16.sp),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    percentage,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
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
          Icons.add_circle,
          'Ajouter Dépense',
          'Nouvelle dépense',
          AppColors.errorColor,
          () => _showAddExpenseDialog(),
        ),
        _buildActionCard(
          Icons.payments,
          'Ajouter Recette',
          'Nouvelle recette',
          AppColors.successColor,
          () => _showAddRevenueDialog(),
        ),
        _buildActionCard(
          Icons.receipt,
          'Factures',
          'Gérer factures',
          AppColors.infoColor,
          () {},
        ),
        _buildActionCard(
          Icons.inventory,
          'Inventaire',
          'Matériel et stock',
          AppColors.warningColor,
          () {},
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

  Widget _buildRecentTransactions() {
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
                    'Transactions Récentes',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  CustomButton(
                    text: 'Voir tout',
                    onPressed: () {},
                    backgroundColor: AppColors.accountantColor,
                    height: 30.h,
                    fontSize: 12.sp,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  itemCount: _getMockTransactions().length,
                  itemBuilder: (context, index) {
                    final transaction = _getMockTransactions()[index];
                    return _buildTransactionCard(transaction);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isExpense = transaction['type'] == 'expense';
    final amount = transaction['amount'] as double;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: (isExpense ? AppColors.errorColor : AppColors.successColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          isExpense ? Icons.remove_circle : Icons.add_circle,
          color: isExpense ? AppColors.errorColor : AppColors.successColor,
          size: 20.sp,
        ),
      ),
      title: Text(
        transaction['description'],
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        transaction['date'],
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isExpense ? '-' : '+'}${amount.toStringAsFixed(2)} DA',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isExpense ? AppColors.errorColor : AppColors.successColor,
            ),
          ),
          Text(
            transaction['category'],
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textHint,
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
      selectedItemColor: AppColors.accountantColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Tableau de bord',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Factures',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Rapports',
        ),
      ],
    );
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مصروف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'الوصف',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'المبلغ (دج)',
                border: OutlineInputBorder(),
                prefixText: 'دج',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'الفئة',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'alimentation', child: Text('التغذية')),
                DropdownMenuItem(value: 'transport', child: Text('النقل')),
                DropdownMenuItem(value: 'activites', child: Text('الأنشطة')),
                DropdownMenuItem(value: 'materiel', child: Text('المعدات')),
                DropdownMenuItem(value: 'personnel', child: Text('الموظفين')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تمت إضافة المصروف بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showAddRevenueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une Recette'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Montant (€)',
                border: OutlineInputBorder(),
                prefixText: '€',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Source',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'inscriptions', child: Text('Inscriptions')),
                DropdownMenuItem(value: 'subventions', child: Text('Subventions')),
                DropdownMenuItem(value: 'activites', child: Text('Activités payantes')),
                DropdownMenuItem(value: 'dons', child: Text('Dons')),
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
                const SnackBar(content: Text('Recette ajoutée avec succès')),
              );
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

  List<Map<String, dynamic>> _getMockTransactions() {
    return [
      {
        'type': 'expense',
        'description': 'شراء المواد الغذائية',
        'amount': 54250.00,
        'category': 'التغذية',
        'date': '28/10/2025',
      },
      {
        'type': 'revenue',
        'description': 'رسوم تسجيل الأطفال',
        'amount': 85000.00,
        'category': 'التسجيلات',
        'date': '27/10/2025',
      },
      {
        'type': 'expense',
        'description': 'إيجار القاعة',
        'amount': 20000.00,
        'category': 'المعدات',
        'date': '26/10/2025',
      },
      {
        'type': 'revenue',
        'description': 'منحة البلدية',
        'amount': 150000.00,
        'category': 'المنح',
        'date': '25/10/2025',
      },
    ];
  }

  Future<void> _logout() async {
    Navigator.of(context).pushReplacementNamed('/login');
  }
}