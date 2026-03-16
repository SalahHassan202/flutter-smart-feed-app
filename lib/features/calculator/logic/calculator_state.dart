import '../data/models/ingredient_model.dart';

abstract class CalculatorState {}

class CalculatorInitial extends CalculatorState {}

class CalculatorUpdated extends CalculatorState {
  final List<IngredientModel> ingredients;
  final double totalCost;
  final double avgProtein;
  final double avgPricePerKilo;

  CalculatorUpdated({
    required this.ingredients,
    required this.totalCost,
    required this.avgProtein,
    required this.avgPricePerKilo,
  });
}
