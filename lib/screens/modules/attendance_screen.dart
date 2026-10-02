import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/timetable_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedPeriod = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchStudents();
      Provider.of<TimetableProvider>(context, listen: false).fetchTimetableAndAttendance();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final timetableProvider = Provider.of<TimetableProvider>(context);

    final isAdmin = auth.isAdmin;
    final currentStudent = auth.currentStudent;

    final filteredStudents = studentProvider.students.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) || s.registerNumber.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Mark Attendance (Period $_selectedPeriod)' : 'My Attendance Record'),
      ),
      body: Column(
        children: [
          // Period Selector Bar (Admin)
          if (isAdmin) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.surfaceVariant,
              child: Row(
                children: [
                  const Text('Select Period: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(8, (i) {
                          final periodNum = i + 1;
                          final isSelected = _selectedPeriod == periodNum;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text('Period $periodNum'),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                              onSelected: (val) => setState(() => _selectedPeriod = periodNum),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Search Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search student by reg no or name...',
                prefixIcon: const Icon(LucideIcons.search, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Student List / Record View
          Expanded(
            child: studentProvider.isLoading || timetableProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : isAdmin
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          final today = DateTime.now().toString().split(' ')[0];
                          final existingRecord = timetableProvider.attendanceRecords.firstWhere(
                            (r) => r.date == today && r.registerNumber == student.registerNumber && r.periodNum == _selectedPeriod,
                            orElse: () => timetableProvider.attendanceRecords.isEmpty
                                ? timetableProvider.attendanceRecords.first
                                : timetableProvider.attendanceRecords.first,
                          );

                          final isPresent = existingRecord.registerNumber == student.registerNumber && existingRecord.status == 'Present';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  student.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                              title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text('Reg: ${student.registerNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ChoiceChip(
                                    label: const Text('Present'),
                                    selected: isPresent,
                                    selectedColor: AppColors.successBg,
                                    labelStyle: TextStyle(color: isPresent ? AppColors.success : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 11),
                                    onSelected: (val) {
                                      timetableProvider.markAttendance(
                                        registerNumber: student.registerNumber,
                                        studentName: student.name,
                                        status: 'Present',
                                        periodNum: _selectedPeriod,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    label: const Text('Absent'),
                                    selected: !isPresent,
                                    selectedColor: AppColors.errorBg,
                                    labelStyle: TextStyle(color: !isPresent ? AppColors.error : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 11),
                                    onSelected: (val) {
                                      timetableProvider.markAttendance(
                                        registerNumber: student.registerNumber,
                                        studentName: student.name,
                                        status: 'Absent',
                                        periodNum: _selectedPeriod,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : _buildStudentAttendanceOverview(context, timetableProvider, currentStudent?.registerNumber ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAttendanceOverview(BuildContext context, TimetableProvider provider, String regNo) {
    final myRecords = provider.attendanceRecords.where((r) => r.registerNumber == regNo).toList();

    if (myRecords.isEmpty) {
      return const Center(child: Text('No attendance records marked yet for today'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myRecords.length,
      itemBuilder: (context, index) {
        final rec = myRecords[index];
        final isPresent = rec.status == 'Present';

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPresent ? AppColors.successBg : AppColors.errorBg,
              child: Icon(
                isPresent ? LucideIcons.check : LucideIcons.x,
                color: isPresent ? AppColors.success : AppColors.error,
              ),
            ),
            title: Text('Period ${rec.periodNum} Attendance', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('Date: ${rec.date}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPresent ? AppColors.successBg : AppColors.errorBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                rec.status.toUpperCase(),
                style: TextStyle(color: isPresent ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}
