import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

/// Stores ingredients that the user adds himself from the app (name +
/// a fixed protein percentage) using SharedPreferences (same local
/// storage already used for saved mixes / history).
///
/// Every custom ingredient is saved as a small JSON object:
/// { "name": "بذرة كتان", "proteinPercentage": 22.0 }
///
/// This means the user can add a brand-new feed item (with its fixed
/// protein %) from inside the app itself, and it will keep showing up
/// on the home page — with its own weight/price fields — forever,
/// without needing a new code change or app update.
class CustomIngredientStorage {
  static const String _key = AppConstants.customIngredientsPrefsKey;

  /// Returns all custom ingredients saved by the user as
  /// [{'name': ..., 'proteinPercentage': ...}, ...]
  static Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList(growable: false);
  }

  /// Saves a new custom ingredient. Returns false if an ingredient with
  /// the same name already exists (built-in or custom check is done by
  /// the caller before calling this).
  static Future<void> add(String name, double proteinPercentage) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode({'name': name, 'proteinPercentage': proteinPercentage}));
    await prefs.setStringList(_key, raw);
  }

  /// Removes a custom ingredient by its name.
  static Future<void> remove(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return map['name'] == name;
    });
    await prefs.setStringList(_key, raw);
  }
}
