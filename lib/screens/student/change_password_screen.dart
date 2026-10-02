import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  String? _error;
  String? _success;

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (newPass.length < 4) {
      setState(() => _error = 'Password must be at least 4 characters');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _error = null;
      _success = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.changeStudentPassword(newPass);

    if (ok && mounted) {
      setState(() {
        _success = 'Password changed successfully!';
        _newPassController.clear();
        _confirmPassController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(LucideIcons.key, size: 40, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text(
                      'Update Account Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Logged in as ${auth.currentStudent?.name ?? 'Student'} (${auth.currentStudent?.registerNumber ?? ''})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),

                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(10)),
                        child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_success != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(10)),
                        child: Text(_success!, style: const TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    CustomTextField(
                      label: 'New Password',
                      hint: 'Enter new password',
                      controller: _newPassController,
                      prefixIcon: LucideIcons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Confirm New Password',
                      hint: 'Re-enter new password',
                      controller: _confirmPassController,
                      prefixIcon: LucideIcons.checkCircle,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Update Password',
                      onPressed: _handleChangePassword,
                      isLoading: auth.isLoading,
                      icon: LucideIcons.save,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
