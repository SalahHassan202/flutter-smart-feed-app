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
      FocusScope.of(context).unfocus();
    }
  }

  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.grey[50],
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: false,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            decoration: _getInputDecoration(AppStrings.ingredientName),
          ),
          Spacing.height(12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  decoration: _getInputDecoration(AppStrings.weight),
                ),
              ),
              Spacing.width(8),
              Expanded(
                child: TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  decoration: _getInputDecoration(AppStrings.price),
                ),
              ),
              Spacing.width(8),
              Expanded(
                child: TextField(
                  controller: proteinController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  decoration: _getInputDecoration(AppStrings.protein),
                ),
              ),
            ],
          ),
          Spacing.height(20),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              AppStrings.addBtn,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
