class IngredientModel {
  final String id;
  final String name;
  final double weight;
  final double pricePerKilo;
  final double proteinPercentage;

  IngredientModel({
    required this.id,
    required this.name,
    required this.weight,
    required this.pricePerKilo,
    required this.proteinPercentage,
  });

  double get totalCost => weight * pricePerKilo;
}
