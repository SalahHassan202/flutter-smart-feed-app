abstract class CalculatorState {}

class CalculatorInitial extends CalculatorState {}

class CalculatorResults extends CalculatorState {
  final double totalCost;
  final double totalWeight;
  final double avgPrice;
  final double avgProtein;

  CalculatorResults({
    required this.totalCost,
    required this.totalWeight,
    required this.avgPrice,
    required this.avgProtein,
  });
}
