import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smart_feed_app/core/constants/app_colors.dart';
import 'package:smart_feed_app/core/constants/app_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../data/models/ingredient_model.dart';
import '../logic/calculator_cubit.dart';
import 'widgets/calculator_results_widget.dart';

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

  Future<void> _takeScreenshot() async {
    final image = await screenshotController.capture();
    if (image != null) {
      await Gal.putImageBytes(image);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الخلطة في المعرض')),
        );
      }
    }
  }

  void _onSave() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('حفظ الخلطة'),
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

  void _onCalculate() {
    for (int i = 0; i < ingredients.length; i++) {
      ingredients[i].weight = double.tryParse(weightControllers[i].text) ?? 0.0;
      ingredients[i].price = double.tryParse(priceControllers[i].text) ?? 0.0;
    }
    context.read<CalculatorCubit>().calculateMix(ingredients);
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
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _onSave),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _takeScreenshot,
          ),
        ],
      ),
      body: Screenshot(
        controller: screenshotController,
        child: Container(
          color: AppColors.background,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: AppColors.cardBg,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                ingredients[index].name,
                                style: AppStyles.font16SemiBold,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: weightControllers[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText: AppStrings.weight,
                                  labelStyle: AppStyles.font14Medium,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: priceControllers[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText: AppStrings.price,
                                  labelStyle: AppStyles.font14Medium,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const CalculatorResultsWidget(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _onCalculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
        ),
      ),
    );
  }
}
