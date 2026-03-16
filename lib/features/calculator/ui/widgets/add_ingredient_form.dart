import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/spacing_helper.dart';
import '../../logic/calculator_cubit.dart';

class AddIngredientForm extends StatefulWidget {
  const AddIngredientForm({super.key});

  @override
  State<AddIngredientForm> createState() => _AddIngredientFormState();
}

class _AddIngredientFormState extends State<AddIngredientForm> {
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final priceController = TextEditingController();
  final proteinController = TextEditingController();

  void _submit() {
    if (nameController.text.isNotEmpty &&
        weightController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        proteinController.text.isNotEmpty) {
      context.read<CalculatorCubit>().addIngredient(
        nameController.text,
        double.parse(weightController.text),
        double.parse(priceController.text),
        double.parse(proteinController.text),
      );
      nameController.clear();
      weightController.clear();
      priceController.clear();
      proteinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.ingredientName,
              ),
            ),
            Spacing.height(10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.weight,
                    ),
                  ),
                ),
                Spacing.width(10),
                Expanded(
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.price,
                    ),
                  ),
                ),
                Spacing.width(10),
                Expanded(
                  child: TextField(
                    controller: proteinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.protein,
                    ),
                  ),
                ),
              ],
            ),
            Spacing.height(20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(AppStrings.addBtn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
