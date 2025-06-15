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

  String selectedIngredient = '';
  bool didSetDefaultIngredient = false;

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

  void setSelectedIngredient(String value) {
    setState(() {
      selectedIngredient = value;
    });
    fetchMeals();
  }

  Widget _buildNoReferenceFoundView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.soup_kitchen, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No recipe recommendations found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try selecting a different ingredient.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recipes ${selectedIngredient == '' ? '' : 'with ${selectedIngredient.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}'}',
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
              if (!didSetDefaultIngredient &&
                  ingredients.isNotEmpty &&
                  !ingredients.contains(selectedIngredient)) {
                selectedIngredient = ingredients.first;
                didSetDefaultIngredient = true;

                // Reset and refetch after first frame to avoid setState during build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setSelectedIngredient(ingredients.first);
                });
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
                    setSelectedIngredient(value);
                  }
                },
              );
            },
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : meals.isEmpty
                ? _buildNoReferenceFoundView()
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
