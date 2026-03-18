import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
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

  final Map<String, double> proteinData = {
    'ذرة': 10.0,
    'عباد': 36.0,
    'صويا': 46.0,
    'قشر صويا': 12.0,
    'رده': 12.0,
    'رجيعه': 12.0,
    'جلوتفيد': 16.0,
    'شعير': 12.0,
    'حت فول': 24.0,
    'مولاس': 10.0,
    'إضافات': 0.0,
    'بلاستيك وخلاط': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    ingredients = proteinData.entries
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
      } else {
        weightControllers[i].clear();
        priceControllers[i].clear();
      }
    }
    _onCalculate();
  }

  void _onCalculate() {
    for (int i = 0; i < ingredients.length; i++) {
      ingredients[i].weight = double.tryParse(weightControllers[i].text) ?? 0.0;
      ingredients[i].price = double.tryParse(priceControllers[i].text) ?? 0.0;
    }
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'حفظ الخلطة',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'مثلاً: خلطة تسمين',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<CalculatorCubit>().saveCurrentMix(
                    controller.text,
                    ingredients,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text(
          "حاسبة الأعلاف",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildAppBarAction(Icons.history_rounded, "القديم", () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
            if (result != null && mounted) {
              setState(() => _loadOldMix(result));
            }
          }),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _buildAppBarAction(Icons.save_rounded, "حفظ", _onSave),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          ingredients[index].name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: _buildInput(
                          weightControllers[index],
                          "الوزن (كجم)",
                          "٠.٠",
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: _buildInput(
                          priceControllers[index],
                          "السعر (جنيه)",
                          "٠.٠",
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildCalculateButton(),
        ],
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
          fontWeight: FontWeight.normal,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade500, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _onCalculate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: const Text(
          "احسب النتائج",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
