import 'package:flutter/material.dart';
import 'package:myapp/app/models/meal_model.dart';
import 'package:myapp/app/services/meal_api_service.dart';

class RecipeReferenceDetailScreen extends StatefulWidget {
  final String idMeal;

  const RecipeReferenceDetailScreen({super.key, required this.idMeal});

  @override
  State<RecipeReferenceDetailScreen> createState() =>
      _RecipeReferenceDetailScreenState();
}

class _RecipeReferenceDetailScreenState
    extends State<RecipeReferenceDetailScreen> {
  final MealApiService _mealApiService = MealApiService();

  MealModel? meal;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMealDetail();
  }

  Future<void> fetchMealDetail() async {
    setState(() => isLoading = true);
    final response = await _mealApiService.getMealById(widget.idMeal);
    if (response.success) {
      setState(() {
        meal = response.data;
      });
    } else {
      print(response.error);
      setState(() {
        meal = null;
      });
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final mealThumb = meal?.strMealThumb ?? '';
    final mealName = meal?.strMeal ?? 'Unknown Meal';
    final category = meal?.strCategory ?? 'N/A';
    final area = meal?.strArea ?? 'N/A';
    final instructions = meal?.strInstructions ?? 'No instructions available.';
    final youtubeLink = meal?.strYoutube ?? '';

    final ingredientWidgets = <Widget>[];
    final ingredientCount = meal == null
        ? 0
        : (meal!.ingredients.length < meal!.measurements.length
              ? meal!.ingredients.length
              : meal!.measurements.length);

    for (int i = 0; i < ingredientCount; i++) {
      final ingredient = meal!.ingredients[i];
      final measure = meal!.measurements[i];
      if (ingredient.isNotEmpty && measure.isNotEmpty) {
        ingredientWidgets.add(Text("- $ingredient: $measure"));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Meal Detail')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : meal == null
          ? Center(child: Text('Failed to load meal details.'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mealThumb.isNotEmpty) Image.network(mealThumb),
                  SizedBox(height: 16),
                  Text(
                    mealName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("Category: $category"),
                  Text("Area: $area"),
                  SizedBox(height: 16),
                  Text("Instructions:", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text(instructions),
                  SizedBox(height: 16),
                  Text("Ingredients:", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  ...ingredientWidgets,
                  SizedBox(height: 16),
                  if (youtubeLink.isNotEmpty) Text("YouTube: $youtubeLink"),
                ],
              ),
            ),
    );
  }
}
