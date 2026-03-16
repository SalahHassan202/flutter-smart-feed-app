import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../data/models/ingredient_model.dart';

class IngredientItemCard extends StatelessWidget {
  final IngredientModel ingredient;
  final VoidCallback onDelete;

  const IngredientItemCard({
    super.key,
    required this.ingredient,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(ingredient.name, style: AppStyles.font16SemiBold),
        subtitle: Text(
          "الوزن: ${ingredient.weight} كجم | بروتين: ${ingredient.proteinPercentage}%",
          style: AppStyles.font14Medium,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
