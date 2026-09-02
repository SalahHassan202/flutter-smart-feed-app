import 'app_strings.dart';

class AppConstants {
  static const Map<String, double> proteinMap = {
    AppStrings.corn: 10.0,
    AppStrings.sunflower: 36.0,
    AppStrings.soy: 46.0,
    AppStrings.soyHulls: 12.0,
    AppStrings.bran: 12.0,
    AppStrings.ragiha: 12.0,
    AppStrings.glutifeed: 16.0,
    AppStrings.barley: 12.0,
    AppStrings.favaBeans: 24.0,
    AppStrings.molasses: 10.0,
    AppStrings.additives: 0.0,
    AppStrings.plasticMixer: 0.0,
    AppStrings.cottonSeed: 22.0,
    AppStrings.flaxSeed: 22.0,
  };

  /// Key used to persist user-added ingredients (name + fixed protein %)
  /// in SharedPreferences, so they survive app restarts and app updates.
  static const String customIngredientsPrefsKey = 'custom_ingredients';
}
