import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/helpers/spacing_helper.dart';

class SummarySection extends StatelessWidget {
  final double totalCost;
  final double avgProtein;
  final double avgPrice;

  const SummarySection({
    super.key,
    required this.totalCost,
    required this.avgProtein,
    required this.avgPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildRow(
            AppStrings.totalCost,
            "${totalCost.toStringAsFixed(2)} ${AppStrings.currency}",
          ),
          Spacing.height(8),
          _buildRow(
            AppStrings.avgProtein,
            "${avgProtein.toStringAsFixed(2)} %",
            isHighlight: true,
          ),
          Spacing.height(8),
          _buildRow(
            AppStrings.finalPrice,
            "${avgPrice.toStringAsFixed(2)} ${AppStrings.currency}",
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppStyles.font14Medium),
        Text(
          value,
          style: isHighlight
              ? AppStyles.font16SemiBold.copyWith(color: AppColors.primary)
              : AppStyles.font16SemiBold,
        ),
      ],
    );
  }
}
