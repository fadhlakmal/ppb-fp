import 'package:flutter/material.dart';
import 'package:myapp/app/models/meal_model.dart';
import 'package:myapp/app/screens/recipe_reference_detail_screen.dart';
import 'package:myapp/app/services/firestore_service.dart';
import 'package:myapp/app/services/meal_api_service.dart';

class RecipeReferenceScreen extends StatefulWidget {
  const RecipeReferenceScreen({super.key});

  @override
  State<RecipeReferenceScreen> createState() => _RecipeReferenceScreenState();
}

class _RecipeReferenceScreenState extends State<RecipeReferenceScreen> {
  final MealApiService _mealApiService = MealApiService();
  final FirestoreService _firestoreService = FirestoreService();

  String selectedIngredient = 'chicken_breast';

  List<MealModel> meals = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMeals();
  }

  Future<void> fetchMeals() async {
    setState(() => isLoading = true);
    final response = await _mealApiService.getMealsByIngredient(
      selectedIngredient,
    );
    if (response.success) {
      setState(() {
        meals = response.data ?? [];
      });
    } else {
      print(response.error);
      setState(() {
        meals = [];
      });
    }
    setState(() => isLoading = false);
  }

  void openRecipeReferenceDetail(String idMeal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeReferenceDetailScreen(idMeal: idMeal),
      ),
    );
  }

  Stream<List<String>> _getUniqueIngredientNamesStream() {
    return _firestoreService.getIngredientsStream().map((ingredientList) {
      final uniqueNames = <String>{}; // a Set automatically removes duplicates

      for (final ingredient in ingredientList) {
        uniqueNames.add(ingredient.name.toLowerCase()); // normalize if needed
      }

      return uniqueNames.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recipes with ${selectedIngredient.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}',
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<List<String>>(
            stream: _getUniqueIngredientNamesStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              final ingredients = snapshot.data!;
              if (!ingredients.contains(selectedIngredient)) {
                selectedIngredient = ingredients.first;
              }

              return DropdownButton<String>(
                value: selectedIngredient,
                items: ingredients.map((ingredient) {
                  return DropdownMenuItem(
                    value: ingredient,
                    child: Text(
                      ingredient
                          .replaceAll('_', ' ')
                          .split(' ')
                          .map(
                            (word) => word[0].toUpperCase() + word.substring(1),
                          )
                          .join(' '),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedIngredient = value;
                    });
                    fetchMeals(); // ⏬ fetch based on selection
                  }
                },
              );
            },
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : meals.isEmpty
                ? Center(child: Text('No meals found.'))
                : ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          leading: Image.network(
                            meal.strMealThumb ?? '',
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                          title: Text(meal.strMeal),
                          onTap: () => openRecipeReferenceDetail(meal.idMeal),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
