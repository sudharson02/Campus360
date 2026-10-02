import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoodProvider>(context, listen: false).fetchFood();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final foodProvider = Provider.of<FoodProvider>(context);

    final isAdmin = auth.isAdmin;
    final food = foodProvider.food;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Dining & Food Counter'),
      ),
      body: foodProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : food == null
              ? const Center(child: Text('No food menu published for today.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Food Banner Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: food.isAvailable
                                ? [const Color(0xFF059669), AppColors.success]
                                : [AppColors.error, const Color(0xFFDC2626)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (food.isAvailable ? AppColors.success : AppColors.error).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              food.isAvailable ? LucideIcons.utensils : LucideIcons.slash,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              food.isAvailable ? 'MEALS AVAILABLE TODAY' : 'Meals Completed / Not Available',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.extrabold, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              food.isAvailable 
                                  ? '${food.remainingMeals} Meals Remaining out of ${food.totalMeals}' 
                                  : 'All prepared meals for today have been served.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Food Menu Card
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(LucideIcons.chefHat, color: AppColors.primary, size: 20),
                                  SizedBox(width: 8),
                                  Text("Today's Campus Menu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Divider(height: 24),
                              Text(
                                food.menuItems,
                                style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatChip('Total Meals Prepared', '${food.totalMeals}'),
                                  _buildStatChip('Students Servable', '${food.servableStudents}'),
                                  _buildStatChip('Remaining', '${food.remainingMeals}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (isAdmin) ...[
                        CustomButton(
                          text: "Update Today's Food Menu & Meals",
                          icon: LucideIcons.edit,
                          onPressed: () => _showUpdateFoodModal(context, foodProvider, food),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  void _showUpdateFoodModal(BuildContext context, FoodProvider provider, dynamic food) {
    final menuController = TextEditingController(text: food.menuItems);
    final totalController = TextEditingController(text: '${food.totalMeals}');
    final servableController = TextEditingController(text: '${food.servableStudents}');
    final remainingController = TextEditingController(text: '${food.remainingMeals}');

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
            const Text('Update Dining Menu & Servings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Today\'s Menu Items', hint: 'South Indian Thali...', controller: menuController, maxLines: 2),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: CustomTextField(label: 'Total Meals', controller: totalController, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: CustomTextField(label: 'Servable Count', controller: servableController, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: CustomTextField(label: 'Remaining', controller: remainingController, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Publish Menu Update',
              icon: LucideIcons.save,
              onPressed: () {
                provider.updateFoodMenu(
                  menuItems: menuController.text.trim(),
                  totalMeals: int.tryParse(totalController.text) ?? 500,
                  servableStudents: int.tryParse(servableController.text) ?? 500,
                  remainingMeals: int.tryParse(remainingController.text) ?? 0,
                );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
