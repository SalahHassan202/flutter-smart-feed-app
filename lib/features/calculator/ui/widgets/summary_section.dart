import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // ignore: deprecated_member_use
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            AppStrings.totalCost,
            totalCost.toStringAsFixed(2),
            AppStrings.currency,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            // ignore: deprecated_member_use
            child: Divider(color: Colors.white.withOpacity(0.2)),
          ),
          _buildInfoRow(
            AppStrings.avgProtein,
            avgProtein.toStringAsFixed(2),
            "%",
            isMain: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            // ignore: deprecated_member_use
            child: Divider(color: Colors.white.withOpacity(0.2)),
          ),
          _buildInfoRow(
            AppStrings.finalPrice,
            avgPrice.toStringAsFixed(2),
            AppStrings.currency,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    String unit, {
    bool isMain = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMain ? 24 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacing.width(4),
            Text(
              unit,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
