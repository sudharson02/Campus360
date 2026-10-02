import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AdminEditStudentScreen extends StatefulWidget {
  final Student? student; // Null if creating new student

  const AdminEditStudentScreen({super.key, this.student});

  @override
  State<AdminEditStudentScreen> createState() => _AdminEditStudentScreenState();
}

class _AdminEditStudentScreenState extends State<AdminEditStudentScreen> {
  late TextEditingController _nameController;
  late TextEditingController _regNoController;
  late TextEditingController _collegeController;
  late TextEditingController _deptController;
  late TextEditingController _yearController;
  late TextEditingController _semController;
  late TextEditingController _passwordController;
  late TextEditingController _imageUrlController;

  final _formKey = GlobalKey<FormState>();
  String? _error;

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameController = TextEditingController(text: s?.name ?? '');
    _regNoController = TextEditingController(text: s?.registerNumber ?? '');
    _collegeController = TextEditingController(text: s?.college ?? AppConstants.collegeName);
    _deptController = TextEditingController(text: s?.department ?? AppConstants.departmentName);
    _yearController = TextEditingController(text: s?.year ?? 'III Year');
    _semController = TextEditingController(text: s?.semester ?? 'V Semester');
    _passwordController = TextEditingController(text: s?.password ?? AppConstants.defaultStudentPassword);
    _imageUrlController = TextEditingController(text: s?.profileImage ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regNoController.dispose();
    _collegeController.dispose();
    _deptController.dispose();
    _yearController.dispose();
    _semController.dispose();
    _passwordController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<StudentProvider>(context, listen: false);
    setState(() => _error = null);

    final studentData = Student(
      id: isEditing ? widget.student!.id : _regNoController.text.trim(),
      registerNumber: _regNoController.text.trim(),
      name: _nameController.text.trim(),
      college: _collegeController.text.trim(),
      department: _deptController.text.trim(),
      year: _yearController.text.trim(),
      semester: _semController.text.trim(),
      password: _passwordController.text.trim(),
      profileImage: _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
      createdAt: widget.student?.createdAt ?? DateTime.now(),
    );

    bool success = false;
    if (isEditing) {
      success = await provider.updateStudent(studentData);
    } else {
      success = await provider.addStudent(studentData);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? 'Student updated successfully!' : 'New student added!')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      setState(() => _error = provider.error ?? 'Error saving student');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Student Details' : 'Add New Student'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(10)),
                  child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
              ],

              CustomTextField(
                label: 'Student Full Name',
                hint: 'e.g. AKSHITHA E',
                controller: _nameController,
                prefixIcon: LucideIcons.user,
                validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'Register Number (Unique Identifier)',
                hint: 'e.g. 812924243001',
                controller: _regNoController,
                prefixIcon: LucideIcons.hash,
                readOnly: isEditing, // Register number is unique ID
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Register Number is required' : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'College',
                hint: 'OASYS Institute of Technology',
                controller: _collegeController,
                prefixIcon: LucideIcons.building,
                validator: (v) => v == null || v.isEmpty ? 'College is required' : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'Department',
                hint: 'B.Tech - Artificial Intelligence and Data Science',
                controller: _deptController,
                prefixIcon: LucideIcons.bookOpen,
                validator: (v) => v == null || v.isEmpty ? 'Department is required' : null,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Year',
                      hint: 'III Year',
                      controller: _yearController,
                      prefixIcon: LucideIcons.calendar,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Semester',
                      hint: 'V Semester',
                      controller: _semController,
                      prefixIcon: LucideIcons.layers,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'Student Password',
                hint: 'Default: passoasys',
                controller: _passwordController,
                prefixIcon: LucideIcons.lock,
                validator: (v) => v == null || v.isEmpty ? 'Password is required' : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'Profile Image URL / Data',
                hint: 'https://images.unsplash.com/... or data string',
                controller: _imageUrlController,
                prefixIcon: LucideIcons.image,
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: isEditing ? 'Save Changes' : 'Create Student Record',
                onPressed: _saveStudent,
                isLoading: provider.isLoading,
                icon: LucideIcons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
