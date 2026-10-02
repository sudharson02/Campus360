import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/student/student_profile_screen.dart';
import '../screens/student/change_password_screen.dart';
import '../screens/admin/admin_student_mgmt_screen.dart';
import '../screens/admin/admin_staff_mgmt_screen.dart';
import '../screens/modules/timetable_screen.dart';
import '../screens/modules/attendance_screen.dart';
import '../screens/modules/complaints_screen.dart';
import '../screens/modules/notifications_screen.dart';
import '../screens/modules/lost_found_screen.dart';
import '../screens/modules/food_screen.dart';
import '../screens/modules/tokens_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isStudent = auth.isStudent;
    final student = auth.currentStudent;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              isStudent ? (student?.name ?? 'Student') : 'Admin (Rajesh)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              isStudent 
                  ? 'Reg: ${student?.registerNumber ?? ''} • AI&DS' 
                  : 'System Administrator',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: isStudent
                  ? Text(
                      student?.name.substring(0, 1).toUpperCase() ?? 'S',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    )
                  : const Icon(LucideIcons.shieldCheck, color: AppColors.primary, size: 28),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (isStudent) ...[
                  ListTile(
                    leading: const Icon(LucideIcons.user, size: 20, color: AppColors.primary),
                    title: const Text('My Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentProfileScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.calendar, size: 20, color: AppColors.secondary),
                    title: const Text('Timetable & Classes'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.checkSquare, size: 20, color: AppColors.success),
                    title: const Text('My Attendance'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.ticket, size: 20, color: AppColors.accent),
                    title: const Text('Token Queues'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TokensScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.utensils, size: 20, color: AppColors.warning),
                    title: const Text('Food Availability'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.search, size: 20, color: Colors.purple),
                    title: const Text('Lost & Found'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LostFoundScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.messageSquare, size: 20, color: AppColors.error),
                    title: const Text('Complaints & Requests'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintsScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.bell, size: 20, color: AppColors.info),
                    title: const Text('Notifications'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(LucideIcons.key, size: 20, color: AppColors.textSecondary),
                    title: const Text('Change Password'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(LucideIcons.users, size: 20, color: AppColors.primary),
                    title: const Text('Student Management'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStudentMgmtScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.userCheck, size: 20, color: AppColors.secondary),
                    title: const Text('Staff Directory'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStaffMgmtScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.checkSquare, size: 20, color: AppColors.success),
                    title: const Text('Mark Attendance'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.messageSquare, size: 20, color: AppColors.error),
                    title: const Text('Complaints Desk'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintsScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.utensils, size: 20, color: AppColors.warning),
                    title: const Text('Food Management'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.ticket, size: 20, color: AppColors.accent),
                    title: const Text('Token Desk'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TokensScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.search, size: 20, color: Colors.purple),
                    title: const Text('Lost & Found Items'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LostFoundScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.bell, size: 20, color: AppColors.info),
                    title: const Text('Broadcast Notifications'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                    },
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(LucideIcons.logOut, color: AppColors.error, size: 20),
            title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            onTap: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
