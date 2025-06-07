class MealModel {
  final String idMeal;
  final String strMeal;
  final String? strDrinkAlternate;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;
  final String? strMealThumb;
  final String? strTags;
  final String? strYoutube;
  final List<String> ingredients;
  final List<String> measurements;

  MealModel({
    required this.idMeal,
    required this.strMeal,
    this.strDrinkAlternate,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    this.strMealThumb,
    this.strTags,
    this.strYoutube,
    required this.ingredients,
    required this.measurements,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measurements = [];

    for (int i = 1; i <= 20; i++) {
      String ingredient = json['strIngredient$i'];
      String measurement = json['strMeasure$i'];

      if (ingredient.trim().isNotEmpty) {
        ingredients.add(ingredient);
        measurements.add(measurement);
      }
    }

    return MealModel(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strDrinkAlternate: json['strDrinkAlternate'],
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions: json['strInstructions'],
      strMealThumb: json['strMealThumb'],
      strTags: json['strTags'],
      strYoutube: json['strYoutube'],
      ingredients: ingredients,
      measurements: measurements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strDrinkAlternate': strDrinkAlternate,
      'strCategory': strCategory,
      'strArea': strArea,
      'strInstructions': strInstructions,
      'strMealThumb': strMealThumb,
      'strTags': strTags,
      'strYoutube': strYoutube,
      'ingredients': ingredients,
      'measurements': measurements,
    };
  }
}
