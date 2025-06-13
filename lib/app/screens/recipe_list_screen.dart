import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app/models/recipe_model.dart';
import 'package:myapp/app/screens/recipe_detail_screen.dart';
import 'package:myapp/app/screens/recipe_reference_screen.dart';
import 'package:myapp/app/services/firestore_service.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _openReference() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecipeReferenceScreen()),
    );
  }

  void _deleteRecipe(String recipeId) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus resep ini? Operasi ini tidak dapat dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            const Center(child: CircularProgressIndicator()),
      );
      try {
        await _firestoreService.deleteRecipe(recipeId);
        Navigator.of(context).pop(); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep berhasil dihapus'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus resep: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openRecipeDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(
          recipe: recipe,
          delete: () async =>
              await _firestoreService.deleteRecipe(recipe.id ?? ''),
        ),
      ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Please login to view your recipes',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRecipeView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No saved recipes yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to search for a recipe',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipe List'), centerTitle: true),
      body: _auth.currentUser == null
          ? _buildNotLoggedInView()
          : Padding(
              padding: EdgeInsetsGeometry.all(12),
              child: StreamBuilder<List<Recipe>>(
                stream: _firestoreService.getRecipesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print(
                      "Error StreamBuilder: ${snapshot.error}",
                    ); // Untuk debugging
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildNoRecipeView();
                  }

                  final recipes = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true, // Penting di dalam SingleChildScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // Agar tidak ada double scroll
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 2.0,
                        child: ListTile(
                          leading: Image.network(
                            recipe.imageUrl,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                          title: Text(recipe.name),
                          onTap: () => _openRecipeDetail(recipe),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: _auth.currentUser != null
          ? FloatingActionButton(
              onPressed: _openReference,
              tooltip: 'Add Recipe',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
