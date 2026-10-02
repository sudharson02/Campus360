import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/drawer_menu.dart';
import '../../widgets/module_card.dart';
import 'admin_student_mgmt_screen.dart';
import 'admin_staff_mgmt_screen.dart';
import '../modules/attendance_screen.dart';
import '../modules/complaints_screen.dart';
import '../modules/food_screen.dart';
import '../modules/tokens_screen.dart';
import '../modules/lost_found_screen.dart';
import '../modules/notifications_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchStudents();
      Provider.of<ComplaintProvider>(context, listen: false).fetchComplaints();
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);

    final totalStudents = studentProvider.totalStudentsCount > 0 ? studentProvider.totalStudentsCount : 51;
    final pendingComplaints = complaintProvider.complaints.where((c) => c.status == 'Pending').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus360 Admin Portal'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const DrawerMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Banner Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF312E81), AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(LucideIcons.shieldCheck, size: 30, color: AppColors.primaryDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${auth.adminUsername ?? 'Rajesh'}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'System Administrator • OASYS O&T',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Top Metrics Cards Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Students', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          '$totalStudents',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const Text('AI&DS Department', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pending Complaints', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          '$pendingComplaints',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.error),
                        ),
                        const Text('Requires Action', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Admin Modules Grid
            const Text(
              'Management Modules',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ModuleCard(
                  title: 'Student Mgmt',
                  subtitle: '51 AI&DS Roster',
                  icon: LucideIcons.users,
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStudentMgmtScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Staff Directory',
                  subtitle: 'Faculty Roster',
                  icon: LucideIcons.userCheck,
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStaffMgmtScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Mark Attendance',
                  subtitle: 'AI&DS Register',
                  icon: LucideIcons.checkSquare,
                  color: AppColors.success,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Complaints',
                  subtitle: 'Review & Respond',
                  icon: LucideIcons.messageSquare,
                  color: AppColors.error,
                  badgeText: pendingComplaints > 0 ? '$pendingComplaints Pending' : null,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintsScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Food Setup',
                  subtitle: 'Daily Meal Count',
                  icon: LucideIcons.utensils,
                  color: AppColors.warning,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Token Queues',
                  subtitle: 'Call Next FIFO',
                  icon: LucideIcons.ticket,
                  color: AppColors.accent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TokensScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Lost & Found',
                  subtitle: 'Manage Reports',
                  icon: LucideIcons.search,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LostFoundScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Notifications',
                  subtitle: 'Broadcast Alerts',
                  icon: LucideIcons.bell,
                  color: AppColors.info,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
