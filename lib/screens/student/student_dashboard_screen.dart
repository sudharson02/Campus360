import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/timetable_provider.dart';
import '../../widgets/drawer_menu.dart';
import '../../widgets/module_card.dart';
import '../student/student_profile_screen.dart';
import '../modules/timetable_screen.dart';
import '../modules/attendance_screen.dart';
import '../modules/complaints_screen.dart';
import '../modules/notifications_screen.dart';
import '../modules/lost_found_screen.dart';
import '../modules/food_screen.dart';
import '../modules/tokens_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
      Provider.of<TimetableProvider>(context, listen: false).fetchTimetableAndAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);
    final timetableProvider = Provider.of<TimetableProvider>(context);
    final student = auth.currentStudent;

    final unreadCount = notifProvider.getUnreadCount(
      isAdmin: false,
      studentRegNo: student?.registerNumber,
    );

    final currentPeriodInfo = timetableProvider.getCurrentPeriodInfo();
    final currentSlot = currentPeriodInfo['currentSlot'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus360 Student Portal'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$unreadCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
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
            // Student Profile Welcome Card
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentProfileScreen()));
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      backgroundImage: (student?.profileImage != null && student!.profileImage!.isNotEmpty)
                          ? NetworkImage(student.profileImage!)
                          : null,
                      child: (student?.profileImage == null || student!.profileImage!.isEmpty)
                          ? Text(
                              student?.name.substring(0, 1).toUpperCase() ?? 'S',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student?.name ?? 'Student',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Reg: ${student?.registerNumber ?? ''} • ${student?.department ?? 'AI&DS'}',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight, color: Colors.white70),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Live Class Period Highlight
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.clock, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT PERIOD (${currentSlot.timeSlot})',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.extrabold, color: AppColors.primary, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currentSlot.subjectCode} - ${currentSlot.subjectName}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Faculty: ${currentSlot.facultyName}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Campus Modules Grid Header
            const Text(
              'Campus Modules',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            // Grid View
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ModuleCard(
                  title: 'Attendance',
                  subtitle: 'AI&DS Register Status',
                  icon: LucideIcons.checkSquare,
                  color: AppColors.success,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Timetable',
                  subtitle: '8 Periods Schedule',
                  icon: LucideIcons.calendar,
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Token System',
                  subtitle: 'OFF / CAN / LIB Queues',
                  icon: LucideIcons.ticket,
                  color: AppColors.accent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TokensScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Food Menu',
                  subtitle: 'Live Meals Available',
                  icon: LucideIcons.utensils,
                  color: AppColors.warning,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Lost & Found',
                  subtitle: 'AI Auto-Matching',
                  icon: LucideIcons.search,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LostFoundScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Complaints',
                  subtitle: 'Student Helpdesk',
                  icon: LucideIcons.messageSquare,
                  color: AppColors.error,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintsScreen()));
                  },
                ),
                ModuleCard(
                  title: 'Notifications',
                  subtitle: 'Personal Alerts',
                  icon: LucideIcons.bell,
                  color: AppColors.info,
                  badgeText: unreadCount > 0 ? '$unreadCount New' : null,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  },
                ),
                ModuleCard(
                  title: 'My Profile',
                  subtitle: 'View Details & Security',
                  icon: LucideIcons.user,
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentProfileScreen()));
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
