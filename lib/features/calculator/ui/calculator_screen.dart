import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smart_feed_app/features/calculator/ui/widgets/results_bottom_sheet.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../data/models/ingredient_model.dart';
import '../logic/calculator_cubit.dart';
import '../logic/calculator_state.dart';
import '../../history/ui/history_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final ScreenshotController screenshotController = ScreenshotController();
  late List<IngredientModel> ingredients;
  late List<TextEditingController> weightControllers;
  late List<TextEditingController> priceControllers;

  @override
  void initState() {
    super.initState();
    ingredients = AppConstants.proteinMap.entries
        .map((e) => IngredientModel(name: e.key, proteinPercentage: e.value))
        .toList();

    weightControllers = List.generate(
      ingredients.length,
      (index) => TextEditingController(),
    );
    priceControllers = List.generate(
      ingredients.length,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in weightControllers) {
      controller.dispose();
    }
    for (var controller in priceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onSave() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('حفظ الخلطة', style: AppStyles.font20Bold),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'أدخل اسم الخلطة'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _updateIngredientsData();
                  context.read<CalculatorCubit>().saveCurrentMix(
                    controller.text,
                    ingredients,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم الحفظ بنجاح')),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _updateIngredientsData() {
    for (int i = 0; i < ingredients.length; i++) {
      ingredients[i].weight = double.tryParse(weightControllers[i].text) ?? 0.0;
      ingredients[i].price = double.tryParse(priceControllers[i].text) ?? 0.0;
    }
  }

  void _onCalculate() {
    _updateIngredientsData();
    context.read<CalculatorCubit>().calculateMix(ingredients);

    final state = context.read<CalculatorCubit>().state;
    if (state is CalculatorResults) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ResultsBottomSheet(
          totalCost: state.totalCost,
          totalWeight: state.totalWeight,
          avgPrice: state.avgPrice,
          avgProtein: state.avgProtein,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.appTitle,
          style: AppStyles.font20Bold.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save_as_rounded),
            onPressed: _onSave,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                return Card(
                  color: AppColors.cardBg,
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            ingredients[index].name,
                            style: AppStyles.font16SemiBold.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            weightControllers[index],
                            AppStrings.weight,
                            '0.0',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            priceControllers[index],
                            AppStrings.price,
                            '0.0',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              boxShadow: [
                // ignore: deprecated_member_use
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _onCalculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                AppStrings.calculate,
                style: AppStyles.font18WhiteBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: AppStyles.font14Medium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppStyles.font14Medium,
        hintText: hint,
        // ignore: deprecated_member_use
        hintStyle: AppStyles.font14Medium.copyWith(
          // ignore: deprecated_member_use
          color: AppColors.textSecondary.withOpacity(0.5),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
