import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/status_badge.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).fetchComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final complaintProvider = Provider.of<ComplaintProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);

    final isAdmin = auth.isAdmin;
    final student = auth.currentStudent;

    final displayComplaints = isAdmin
        ? complaintProvider.complaints
        : complaintProvider.getComplaintsForStudent(student?.registerNumber ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Complaints Desk' : 'My Complaints & Requests'),
      ),
      floatingActionButton: !isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showSubmitComplaintModal(context, complaintProvider, notifProvider, student!),
              backgroundColor: AppColors.primary,
              icon: const Icon(LucideIcons.plus, color: Colors.white),
              label: const Text('Submit Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: complaintProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : displayComplaints.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.messageSquare, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text('No complaints recorded', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayComplaints.length,
                  itemBuilder: (context, index) {
                    final complaint = displayComplaints[index];
                    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(complaint.createdAt);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    complaint.category.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                                StatusBadge(status: complaint.status),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              complaint.subject,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              complaint.description,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(LucideIcons.user, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 6),
                                Text(
                                  '${complaint.studentName} (${complaint.registerNumber})',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                Text(dateStr, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              ],
                            ),

                            // Admin Response Container
                            if (complaint.adminResponse.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.primary),
                                        SizedBox(width: 6),
                                        Text('Admin Remark', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      complaint.adminResponse,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            if (isAdmin) ...[
                              const Divider(height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  icon: const Icon(LucideIcons.edit3, size: 16),
                                  label: const Text('Respond / Update Status'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    minimumSize: const Size(180, 40),
                                  ),
                                  onPressed: () => _showAdminResponseModal(context, complaintProvider, notifProvider, complaint),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showSubmitComplaintModal(
    BuildContext context,
    ComplaintProvider provider,
    NotificationProvider notifProvider,
    dynamic student,
  ) {
    final categoryController = TextEditingController(text: 'Academic');
    final subjectController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Submit Complaint / Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Category', hint: 'Academic, Hostel, Infrastructure, Canteen', controller: categoryController),
            const SizedBox(height: 12),
            CustomTextField(label: 'Subject', hint: 'e.g. Lab Projector Not Working', controller: subjectController),
            const SizedBox(height: 12),
            CustomTextField(label: 'Description', hint: 'Describe your issue in detail...', controller: descController, maxLines: 3),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Submit Complaint',
              icon: LucideIcons.send,
              onPressed: () async {
                if (subjectController.text.trim().isNotEmpty && descController.text.trim().isNotEmpty) {
                  await provider.submitComplaint(
                    studentName: student.name,
                    registerNumber: student.registerNumber,
                    category: categoryController.text.trim(),
                    subject: subjectController.text.trim(),
                    description: descController.text.trim(),
                    notificationProvider: notifProvider,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminResponseModal(
    BuildContext context,
    ComplaintProvider provider,
    NotificationProvider notifProvider,
    Complaint complaint,
  ) {
    String selectedStatus = complaint.status;
    final responseController = TextEditingController(text: complaint.adminResponse);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Complaint #${complaint.id.substring(0, 6)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Set Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Pending', 'In Progress', 'Resolved', 'Rejected'].map((st) {
                  return ChoiceChip(
                    label: Text(st),
                    selected: selectedStatus == st,
                    onSelected: (val) => setModalState(() => selectedStatus = st),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Admin Response Remark',
                hint: 'Enter response message for student...',
                controller: responseController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Send Response to Student',
                icon: LucideIcons.send,
                onPressed: () async {
                  await provider.updateComplaintStatus(
                    complaintId: complaint.id,
                    status: selectedStatus,
                    adminResponse: responseController.text.trim(),
                    notificationProvider: notifProvider,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
