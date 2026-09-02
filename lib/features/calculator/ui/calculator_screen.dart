import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../data/custom_ingredient_storage.dart';
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
  List<IngredientModel> ingredients = [];
  List<TextEditingController> weightControllers = [];
  List<TextEditingController> priceControllers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    for (final c in weightControllers) {
      c.dispose();
    }
    for (final c in priceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// Builds the full ingredients list: the fixed, built-in ingredients
  /// (from AppConstants.proteinMap, which now also has بذرة/كتان at 22%)
  /// plus any ingredient the user added himself from the app, loaded from
  /// local storage.
  Future<void> _initData() async {
    final List<IngredientModel> builtIn = AppConstants.proteinMap.entries
        .map((e) => IngredientModel(name: e.key, proteinPercentage: e.value))
        .toList();

    final List<Map<String, dynamic>> customData =
        await CustomIngredientStorage.getAll();
    final List<IngredientModel> custom = customData
        .map(
          (e) => IngredientModel(
            name: e['name'] as String,
            proteinPercentage: (e['proteinPercentage'] as num).toDouble(),
            isCustom: true,
          ),
        )
        .toList();

    final List<IngredientModel> all = [...builtIn, ...custom];

    if (!mounted) return;
    setState(() {
      ingredients = all;
      weightControllers = List.generate(
        ingredients.length,
        (index) => TextEditingController(),
      );
      priceControllers = List.generate(
        ingredients.length,
        (index) => TextEditingController(),
      );
      _isLoading = false;
    });
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

  /// Lets the user add a brand-new feed item (name + fixed protein %)
  /// straight from the app. It gets saved to local storage and, from
  /// this point on, always shows up on the home page as a normal row
  /// with its own weight/price fields — with no code changes needed.
  Future<void> _onAddIngredient() async {
    final nameController = TextEditingController();
    final proteinController = TextEditingController();
    String? errorText;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                'إضافة خامة جديدة',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'اسم الخامة (مثلاً: بذرة كتان)',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: proteinController,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'نسبة البروتين %',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final protein = double.tryParse(
                      proteinController.text.trim(),
                    );

                    if (name.isEmpty || protein == null) {
                      setDialogState(() {
                        errorText = 'من فضلك اكتب اسم صحيح ونسبة بروتين صحيحة';
                      });
                      return;
                    }

                    final alreadyExists = ingredients.any(
                      (i) => i.name == name,
                    );
                    if (alreadyExists) {
                      setDialogState(() {
                        errorText = 'الخامة دي موجودة بالفعل';
                      });
                      return;
                    }

                    await CustomIngredientStorage.add(name, protein);

                    if (!mounted) return;
                    setState(() {
                      ingredients.add(
                        IngredientModel(
                          name: name,
                          proteinPercentage: protein,
                          isCustom: true,
                        ),
                      );
                      weightControllers.add(TextEditingController());
                      priceControllers.add(TextEditingController());
                    });

                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'إضافة',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Long-press on a custom ingredient row to remove it permanently.
  Future<void> _onDeleteCustomIngredient(int index) async {
    final name = ingredients[index].name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'حذف الخامة',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد حذف "$name" نهائياً؟',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CustomIngredientStorage.remove(name);
      if (!mounted) return;
      setState(() {
        weightControllers[index].dispose();
        priceControllers[index].dispose();
        ingredients.removeAt(index);
        weightControllers.removeAt(index);
        priceControllers.removeAt(index);
      });
    }
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddIngredient,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "إضافة خامة",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      final row = Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: ingredient.isCustom
                              ? Border.all(
                                  color: AppColors.primary.withOpacity(0.35),
                                  width: 1,
                                )
                              : null,
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
                                ingredient.name,
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

                      // Custom (user-added) ingredients can be removed
                      // with a long-press, without touching the code.
                      if (ingredient.isCustom) {
                        return GestureDetector(
                          onLongPress: () =>
                              _onDeleteCustomIngredient(index),
                          child: row,
                        );
                      }
                      return row;
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
