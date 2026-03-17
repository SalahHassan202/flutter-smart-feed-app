import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_feed_app/core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../logic/calculator_cubit.dart';
import '../../logic/calculator_state.dart';

class CalculatorResultsWidget extends StatelessWidget {
  const CalculatorResultsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        if (state is CalculatorResults) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildResultItem(
                      AppStrings.totalCost,
                      state.totalCost.toStringAsFixed(2),
                      AppStrings.currency,
                    ),
                    _buildDivider(),
                    _buildResultItem(
                      AppStrings.totalWeight,
                      state.totalWeight.toStringAsFixed(2),
                      AppStrings.kg,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildResultItem(
                      AppStrings.pricePerKilo,
                      state.avgPrice.toStringAsFixed(2),
                      AppStrings.currency,
                    ),
                    _buildDivider(),
                    _buildResultItem(
                      AppStrings.proteinPercentage,
                      state.avgProtein.toStringAsFixed(2),
                      '%',
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildResultItem(String label, String value, String unit) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.white, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            '$value $unit',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      // ignore: deprecated_member_use
      color: AppColors.white.withOpacity(0.3),
    );
  }
}
