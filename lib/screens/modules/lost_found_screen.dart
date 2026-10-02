import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../models/lost_found_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lost_found_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/status_badge.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LostFoundProvider>(context, listen: false).fetchItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final provider = Provider.of<LostFoundProvider>(context);

    final isAdmin = auth.isAdmin;
    final student = auth.currentStudent;
    final matches = provider.getAIMatches();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Lost & Found Desk'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: 'LOST (${provider.lostItems.length})'),
            Tab(text: 'FOUND (${provider.foundItems.length})'),
            Tab(text: 'AI MATCHES (${matches.length})'),
          ],
        ),
      ),
      floatingActionButton: !isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showReportItemModal(context, provider, student!),
              backgroundColor: AppColors.primary,
              icon: const Icon(LucideIcons.plus, color: Colors.white),
              label: const Text('Report Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildItemList(context, provider.lostItems, isAdmin, provider),
                _buildItemList(context, provider.foundItems, isAdmin, provider),
                _buildAIMatchList(context, matches),
              ],
            ),
    );
  }

  Widget _buildItemList(BuildContext context, List<LostFoundItem> items, bool isAdmin, LostFoundProvider provider) {
    if (items.isEmpty) {
      return const Center(child: Text('No items reported in this section'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
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
                        color: item.type == 'lost' ? AppColors.errorBg : AppColors.successBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.type.toUpperCase(),
                        style: TextStyle(
                          color: item.type == 'lost' ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    StatusBadge(status: item.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 12),

                // Item Details Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('Location: ${item.location}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          const Icon(LucideIcons.calendar, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(item.date, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(LucideIcons.user, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Reported by: ${item.studentName} (${item.registerNumber}) • ${item.department}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (isAdmin) ...[
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(LucideIcons.checkCircle, size: 16),
                        label: const Text('Toggle Status'),
                        onPressed: () {
                          provider.updateItem(item.copyWith(
                            status: item.status == 'Open' ? 'Resolved' : 'Open',
                          ));
                        },
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                        onPressed: () => provider.deleteItem(item.id),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAIMatchList(BuildContext context, List<LostFoundMatchResult> matches) {
    if (matches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.sparkles, size: 48, color: AppColors.primary),
            SizedBox(height: 12),
            Text('AI Searching for Potential Matches...', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            SizedBox(height: 4),
            Text('Matching Lost items against Found items automatically.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.sparkles, color: AppColors.accent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'AI MATCH CONFIDENCE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accent, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Text(
                        '${match.matchPercentage}% Match',
                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Reason: ${match.matchReason}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const Divider(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('LOST ITEM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error)),
                          Text(match.lostItem.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(match.lostItem.studentName, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.arrowRightLeft, color: AppColors.primary),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('FOUND ITEM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success)),
                          Text(match.foundItem.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(match.foundItem.studentName, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReportItemModal(BuildContext context, LostFoundProvider provider, dynamic student) {
    String type = 'lost';
    final titleController = TextEditingController();
    final categoryController = TextEditingController(text: 'Personal Belongings');
    final descController = TextEditingController();
    final locController = TextEditingController();
    final dateController = TextEditingController(text: DateTime.now().toString().split(' ')[0]);

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
              const Text('Report Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('I Lost an Item'),
                      selected: type == 'lost',
                      selectedColor: AppColors.errorBg,
                      onSelected: (val) => setModalState(() => type = 'lost'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('I Found an Item'),
                      selected: type == 'found',
                      selectedColor: AppColors.successBg,
                      onSelected: (val) => setModalState(() => type = 'found'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(label: 'Item Title', hint: 'e.g. Blue Milton Water Bottle', controller: titleController),
              const SizedBox(height: 12),
              CustomTextField(label: 'Category', hint: 'Electronics, Books, Belongings', controller: categoryController),
              const SizedBox(height: 12),
              CustomTextField(label: 'Location', hint: 'e.g. LH-302 or Canteen', controller: locController),
              const SizedBox(height: 12),
              CustomTextField(label: 'Description', hint: 'Describe color, marks, specs...', controller: descController, maxLines: 2),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Submit Report',
                icon: LucideIcons.send,
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty && descController.text.trim().isNotEmpty) {
                    provider.addItem(LostFoundItem(
                      id: 'lf_${DateTime.now().millisecondsSinceEpoch}',
                      type: type,
                      title: titleController.text.trim(),
                      category: categoryController.text.trim(),
                      description: descController.text.trim(),
                      location: locController.text.trim(),
                      date: dateController.text.trim(),
                      studentName: student.name,
                      registerNumber: student.registerNumber,
                      department: student.department,
                      createdAt: DateTime.now(),
                    ));
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
