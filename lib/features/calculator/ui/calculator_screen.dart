import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/helpers/spacing_helper.dart';
import '../logic/calculator_cubit.dart';
import '../logic/calculator_state.dart';
import 'widgets/add_ingredient_form.dart';
import 'widgets/ingredient_item_card.dart';
import 'widgets/summary_section.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalculatorCubit(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.appTitle, style: AppStyles.font20Bold),
            centerTitle: true,
            actions: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.error),
                    onPressed: () => context.read<CalculatorCubit>().reset(),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const AddIngredientForm(),
                Spacing.height(16),
                Expanded(
                  child: BlocBuilder<CalculatorCubit, CalculatorState>(
                    builder: (context, state) {
                      if (state is CalculatorUpdated) {
                        return ListView.builder(
                          itemCount: state.ingredients.length,
                          itemBuilder: (context, index) {
                            final item = state.ingredients[index];
                            return IngredientItemCard(
                              ingredient: item,
                              onDelete: () => context
                                  .read<CalculatorCubit>()
                                  .deleteIngredient(item.id),
                            );
                          },
                        );
                      }
                      return const Center(child: Text(AppStrings.emptyList));
                    },
                  ),
                ),
                BlocBuilder<CalculatorCubit, CalculatorState>(
                  builder: (context, state) {
                    if (state is CalculatorUpdated) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16, top: 8),
                        child: SummarySection(
                          totalCost: state.totalCost,
                          avgProtein: state.avgProtein,
                          avgPrice: state.avgPricePerKilo,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
