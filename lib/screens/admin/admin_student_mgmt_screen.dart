import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import 'admin_edit_student_screen.dart';

class AdminStudentMgmtScreen extends StatefulWidget {
  const AdminStudentMgmtScreen({super.key});

  @override
  State<AdminStudentMgmtScreen> createState() => _AdminStudentMgmtScreenState();
}

class _AdminStudentMgmtScreenState extends State<AdminStudentMgmtScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchStudents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);

    final filteredStudents = provider.students.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) || s.registerNumber.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Directory (${provider.students.length})'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEditStudentScreen()));
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(LucideIcons.userPlus, color: Colors.white),
        label: const Text('Add Student', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by Register No or Name...',
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

          // Student Roster List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStudents.isEmpty
                    ? const Center(child: Text('No matching students found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryLight,
                                backgroundImage: (student.profileImage != null && student.profileImage!.isNotEmpty)
                                    ? NetworkImage(student.profileImage!)
                                    : null,
                                child: (student.profileImage == null || student.profileImage!.isEmpty)
                                    ? Text(
                                        student.name.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                      )
                                    : null,
                              ),
                              title: Text(
                                student.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Text(
                                'Reg: ${student.registerNumber}\n${student.department}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(LucideIcons.edit2, size: 18, color: AppColors.primary),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => AdminEditStudentScreen(student: student)),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                                    onPressed: () {
                                      _confirmDelete(context, provider, student);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, StudentProvider provider, Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student Record?'),
        content: Text('Are you sure you want to delete ${student.name} (${student.registerNumber})? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteStudent(student.registerNumber);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
