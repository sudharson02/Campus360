import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../models/staff_model.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/status_badge.dart';

class AdminStaffMgmtScreen extends StatefulWidget {
  const AdminStaffMgmtScreen({super.key});

  @override
  State<AdminStaffMgmtScreen> createState() => _AdminStaffMgmtScreenState();
}

class _AdminStaffMgmtScreenState extends State<AdminStaffMgmtScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StaffProvider>(context, listen: false).fetchStaff();
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = Provider.of<StaffProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Management (${staffProvider.staffList.length})'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStaffModal(context, staffProvider),
        backgroundColor: AppColors.secondary,
        icon: const Icon(LucideIcons.userPlus, color: Colors.white),
        label: const Text('Add Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: staffProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : staffProvider.staffList.isEmpty
              ? const Center(child: Text('No staff members registered'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: staffProvider.staffList.length,
                  itemBuilder: (context, index) {
                    final staff = staffProvider.staffList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        staff.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        '${staff.roleTitle} • ${staff.department}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: staff.status),
                              ],
                            ),
                            if (staff.status == 'Absent' && staff.assignedAlternative != 'None') ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.warningBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Alternative Staff: ${staff.assignedAlternative}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(LucideIcons.userCheck, size: 16),
                                  label: const Text('Update Status'),
                                  onPressed: () => _showStatusUpdateModal(context, staffProvider, staff),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                                  onPressed: () => staffProvider.deleteStaff(staff.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddStaffModal(BuildContext context, StaffProvider provider) {
    final nameController = TextEditingController();
    final roleController = TextEditingController(text: 'Assistant Professor');

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
            const Text('Add Faculty Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Faculty Name', hint: 'e.g. Mr N. Sabarivasan', controller: nameController),
            const SizedBox(height: 12),
            CustomTextField(label: 'Designation / Role', hint: 'e.g. Assistant Professor', controller: roleController),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Save Staff',
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  provider.addStaff(Staff(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    roleTitle: roleController.text.trim(),
                  ));
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateModal(BuildContext context, StaffProvider provider, Staff staff) {
    String status = staff.status;
    final altController = TextEditingController(text: staff.assignedAlternative == 'None' ? '' : staff.assignedAlternative);

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
              Text('Update Status: ${staff.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Present'),
                      selected: status == 'Present',
                      onSelected: (val) => setModalState(() => status = 'Present'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Absent'),
                      selected: status == 'Absent',
                      selectedColor: AppColors.errorBg,
                      onSelected: (val) => setModalState(() => status = 'Absent'),
                    ),
                  ),
                ],
              ),
              if (status == 'Absent') ...[
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Assigned Alternative Staff',
                  hint: 'e.g. Mr N. Sabarivasan',
                  controller: altController,
                ),
              ],
              const SizedBox(height: 20),
              CustomButton(
                text: 'Save Attendance Status',
                onPressed: () {
                  provider.updateStaffStatus(
                    staff.id,
                    status,
                    status == 'Absent' ? (altController.text.trim().isEmpty ? 'None' : altController.text.trim()) : 'None',
                  );
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
