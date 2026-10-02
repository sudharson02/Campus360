import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../student/student_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _studentRegController = TextEditingController(text: '812924243001');
  final _studentPasswordController = TextEditingController(text: 'passoasys');

  final _adminUsernameController = TextEditingController(text: 'Rajesh');
  final _adminPasswordController = TextEditingController(text: 'nira31');

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentRegController.dispose();
    _studentPasswordController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (_tabController.index == 0) {
      // Student Login
      final success = await auth.loginStudent(
        _studentRegController.text,
        _studentPasswordController.text,
      );
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
        );
      }
    } else {
      // Admin Login
      final success = await auth.loginAdmin(
        _adminUsernameController.text,
        _adminPasswordController.text,
      );
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Header Logo Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.graduationCap,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.extrabold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  AppConstants.collegeName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  AppConstants.departmentName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Card Container
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tab Bar
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorColor: AppColors.primary,
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.textSecondary,
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              indicator: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                              tabs: const [
                                Tab(text: 'STUDENT'),
                                Tab(text: 'ADMIN'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Error Banner
                          if (auth.error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.errorBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.error.withOpacity(0.3)),
                              ),
                              child: Text(
                                auth.error!,
                                style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Tab View Fields
                          SizedBox(
                            height: 190,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Student Tab
                                Column(
                                  children: [
                                    CustomTextField(
                                      label: 'Register Number',
                                      hint: 'e.g. 812924243001',
                                      controller: _studentRegController,
                                      prefixIcon: LucideIcons.user,
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      label: 'Password',
                                      hint: 'Default: passoasys',
                                      controller: _studentPasswordController,
                                      prefixIcon: LucideIcons.lock,
                                      obscureText: true,
                                    ),
                                  ],
                                ),
                                // Admin Tab
                                Column(
                                  children: [
                                    CustomTextField(
                                      label: 'Admin Username',
                                      hint: 'Username: Rajesh',
                                      controller: _adminUsernameController,
                                      prefixIcon: LucideIcons.shieldCheck,
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      label: 'Admin Password',
                                      hint: 'Password: nira31',
                                      controller: _adminPasswordController,
                                      prefixIcon: LucideIcons.lock,
                                      obscureText: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          CustomButton(
                            text: 'Login to Campus360',
                            onPressed: _submitLogin,
                            isLoading: auth.isLoading,
                            icon: LucideIcons.logIn,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Centralized Supabase Database • OASYS O&T',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
