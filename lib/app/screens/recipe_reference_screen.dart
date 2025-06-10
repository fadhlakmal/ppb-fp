import 'package:flutter/material.dart';
import 'package:myapp/app/models/meal_model.dart';
import 'package:myapp/app/screens/recipe_reference_detail_screen.dart';
import 'package:myapp/app/services/meal_api_service.dart';

class RecipeReferenceScreen extends StatefulWidget {
  const RecipeReferenceScreen({super.key});

  @override
  State<RecipeReferenceScreen> createState() => _RecipeReferenceScreenState();
}

class _RecipeReferenceScreenState extends State<RecipeReferenceScreen> {
  final MealApiService _mealApiService = MealApiService();

  String selectedIngredient = 'chicken_breast';
  List<String> ingredients = [
    'chicken_breast',
    'salmon',
    'beef',
    'chilli',
    'rice',
    'tomato',
    'onion',
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meals with ${selectedIngredient.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}',
        ),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedIngredient,
            items: ingredients
                .map(
                  (ingredient) => DropdownMenuItem(
                    value: ingredient,
                    child: Text(ingredient.replaceAll('_', ' ').toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedIngredient = value;
                });
                fetchMeals();
              }
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
