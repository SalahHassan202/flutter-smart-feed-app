import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calculator_state.dart';
import '../data/models/ingredient_model.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(CalculatorInitial());

  void calculateMix(List<IngredientModel> ingredients) {
    double totalWeight = 0;
    double totalCost = 0;
    double totalProteinAmount = 0;

    for (var item in ingredients) {
      if (item.weight > 0) {
        totalWeight += item.weight;
        totalCost += item.totalIngredientCost;
        totalProteinAmount += item.proteinAmount;
      }
    }

    if (totalWeight == 0) {
      emit(CalculatorInitial());
      return;
    }

    emit(
      CalculatorResults(
        totalCost: totalCost,
        totalWeight: totalWeight,
        avgPrice: totalCost / totalWeight,
        avgProtein: (totalProteinAmount / totalWeight) * 100,
      ),
    );
  }

  Future<void> saveCurrentMix(
    String mixName,
    List<IngredientModel> ingredients,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedMixes = prefs.getStringList('saved_mixes') ?? [];

    final Map<String, dynamic> mixData = {
      'name': mixName,
      'date': DateTime.now().toIso8601String(),
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
    };

    savedMixes.add(jsonEncode(mixData));
    await prefs.setStringList('saved_mixes', savedMixes);
  }

  Future<List<Map<String, dynamic>>> getSavedMixes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('saved_mixes') ?? [];
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}
