import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/app/models/recipe_model.dart';
import 'package:myapp/app/models/user_ingredient_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // INGREDIENTS
  Future<void> addIngredient(Ingredient ingredient) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Pengguna tidak login atau ID pengguna tidak ditemukan.");
    }
    try {
      final newIngredient = Ingredient(
        name: ingredient.name,
        quantity: ingredient.quantity,
        unit: ingredient.unit,
        userId: userId,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      await _db.collection('ingredients').add(newIngredient.toFirestore());
    } catch (e) {
      print("Error adding ingredient: $e");
      rethrow;
    }
  }

  Stream<List<Ingredient>> getIngredientsStream() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.value([]);
    }
    return _db
        .collection('ingredients')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Ingredient.fromFirestore(doc, null))
              .toList();
        });
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Pengguna tidak login atau ID pengguna tidak ditemukan.");
    }
    if (ingredient.id == null) {
      throw Exception("ID bahan makanan tidak boleh null untuk update.");
    }
    try {
      final updatedIngredient = Ingredient(
        id: ingredient.id,
        name: ingredient.name,
        quantity: ingredient.quantity,
        unit: ingredient.unit,
        userId: userId,
        createdAt: ingredient.createdAt,
        updatedAt: Timestamp.now(),
      );
      await _db
          .collection('ingredients')
          .doc(ingredient.id)
          .update(updatedIngredient.toFirestore());
    } catch (e) {
      print("Error updating ingredient: $e");
      rethrow;
    }
  }

  Future<void> deleteIngredient(String ingredientId) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Pengguna tidak login atau ID pengguna tidak ditemukan.");
    }
    try {
      await _db.collection('ingredients').doc(ingredientId).delete();
    } catch (e) {
      print("Error deleting ingredient: $e");
      rethrow;
    }
  }

  // RECIPES

  Future<void> addRecipe(Recipe recipe) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Pengguna tidak login atau ID pengguna tidak ditemukan.");
    }
    try {
      final newRecipe = Recipe(
        name: recipe.name,
        category: recipe.category,
        area: recipe.area,
        instructions: recipe.instructions,
        imageUrl: recipe.imageUrl,
        userId: userId,
        ingredients: recipe.ingredients,
        measurements: recipe.measurements,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      await _db.collection('recipes').add(newRecipe.toFirestore());
    } catch (e) {
      print("Error adding recipe: $e");
      rethrow;
    }
  }

  Stream<List<Recipe>> getRecipesStream() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.value([]);
    }
    return _db
        .collection('recipes')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Recipe.fromFirestore(doc, null))
              .toList();
        });
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Pengguna tidak login atau ID pengguna tidak ditemukan.");
    }
    if (recipe.id == null) {
      throw Exception("ID resep tidak boleh null untuk update.");
    }
    try {
      final updatedRecipe = Recipe(
        id: recipe.id,
        name: recipe.name,
        category: recipe.category,
        area: recipe.area,
        instructions: recipe.instructions,
        imageUrl: recipe.imageUrl,
        userId: userId,
        ingredients: recipe.ingredients,
        measurements: recipe.measurements,
        createdAt: recipe.createdAt,
        updatedAt: Timestamp.now(),
      );
      await _db
          .collection('recipes')
          .doc(recipe.id)
          .update(updatedRecipe.toFirestore());
    } catch (e) {
      print("Error updating recipe: $e");
      rethrow;
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Pengguna tidak login atau ID pengguna tidak ditemukan.");
    }
    try {
      await _db.collection('recipes').doc(recipeId).delete();
    } catch (e) {
      print("Error deleting recipe: $e");
      rethrow;
    }
  }
}
