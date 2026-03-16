import 'package:flutter_bloc/flutter_bloc.dart';
import 'calculator_state.dart';
import '../data/models/ingredient_model.dart';
import 'package:uuid/uuid.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(CalculatorInitial());

  List<IngredientModel> ingredients = [];

  void addIngredient(String name, double weight, double price, double protein) {
    final newItem = IngredientModel(
      id: const Uuid().v4(),
      name: name,
      weight: weight,
      pricePerKilo: price,
      proteinPercentage: protein,
    );
    ingredients.add(newItem);
    _calculateTotals();
  }

  void deleteIngredient(String id) {
    ingredients.removeWhere((item) => item.id == id);
    _calculateTotals();
  }

  void reset() {
    ingredients.clear();
    _calculateTotals();
  }

  void _calculateTotals() {
    if (ingredients.isEmpty) {
      emit(CalculatorInitial());
      return;
    }

    double totalWeight = ingredients.fold(0, (sum, item) => sum + item.weight);
    double totalCost = ingredients.fold(0, (sum, item) => sum + item.totalCost);
    double totalProteinUnits = ingredients.fold(
      0,
      (sum, item) => sum + (item.weight * item.proteinPercentage),
    );

    emit(
      CalculatorUpdated(
        ingredients: List.from(ingredients),
        totalCost: totalCost,
        avgProtein: totalWeight > 0 ? totalProteinUnits / totalWeight : 0,
        avgPricePerKilo: totalWeight > 0 ? totalCost / totalWeight : 0,
      ),
    );
  }
}
