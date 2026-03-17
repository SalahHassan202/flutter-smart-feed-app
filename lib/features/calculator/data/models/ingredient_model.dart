class IngredientModel {
  final String name;
  double weight;
  double price;
  final double proteinPercentage;

  IngredientModel({
    required this.name,
    this.weight = 0.0,
    this.price = 0.0,
    required this.proteinPercentage,
  });

  double get totalIngredientCost => weight * price;

  double get proteinAmount => (weight * proteinPercentage) / 100;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weight': weight,
      'price': price,
      'proteinPercentage': proteinPercentage,
    };
  }

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      name: json['name'],
      weight: (json['weight'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      proteinPercentage: (json['proteinPercentage'] as num).toDouble(),
    );
  }
}
