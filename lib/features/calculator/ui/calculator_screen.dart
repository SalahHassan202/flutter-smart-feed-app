import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../data/models/ingredient_model.dart';
import '../logic/calculator_cubit.dart';
import '../logic/calculator_state.dart';
import '../../history/ui/history_screen.dart';
import 'widgets/results_bottom_sheet.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late List<IngredientModel> ingredients;
  late List<TextEditingController> weightControllers;
  late List<TextEditingController> priceControllers;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
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

  void _loadOldMix(Map<String, dynamic> mixData) {
    List<dynamic> savedIngredients = mixData['ingredients'];
    for (int i = 0; i < ingredients.length; i++) {
      var match = savedIngredients.firstWhere(
        (element) => element['name'] == ingredients[i].name,
        orElse: () => null,
      );
      if (match != null) {
        weightControllers[i].text = match['weight'].toString();
        priceControllers[i].text = match['price'].toString();
      }
    }
    _onCalculate();
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
                  _updateIngredientsData();
                  context.read<CalculatorCubit>().saveCurrentMix(
                    controller.text,
                    ingredients,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "حاسبة الأعلاف",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          _buildAppBarAction(Icons.history_rounded, "الأرشيف", () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
            if (result != null) _loadOldMix(result);
          }),
          _buildAppBarAction(Icons.save_rounded, "حفظ", _onSave),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                Color itemColor = AppColors
                    .pastelColors[index % AppColors.pastelColors.length];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: itemColor,
                    borderRadius: BorderRadius.circular(16),
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
                        flex: 3,
                        child: _buildInput(
                          weightControllers[index],
                          "الوزن (كجم)",
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: _buildInput(
                          priceControllers[index],
                          "السعر (جنيه)",
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: ElevatedButton(
              onPressed: _onCalculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "احسب النتائج",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            Text(label, style: const TextStyle(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
