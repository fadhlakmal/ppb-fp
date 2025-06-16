import 'package:flutter/material.dart';
import 'package:myapp/app/models/user_ingredient_model.dart';
import 'package:myapp/app/services/firestore_service.dart';

class AddIngredientScreen extends StatefulWidget {
  const AddIngredientScreen({super.key});

  @override
  State<AddIngredientScreen> createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  String? _selectedIngredientId;
  Ingredient? _selectedIngredientForEdit;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _quantityController.clear();
    _unitController.clear();
    setState(() {
      _selectedIngredientId = null;
      _selectedIngredientForEdit = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _populateFormForEdit(Ingredient ingredient) {
    setState(() {
      _selectedIngredientId = ingredient.id;
      _selectedIngredientForEdit = ingredient;
      _nameController.text = ingredient.name;
      _quantityController.text = ingredient.quantity.toStringAsFixed(
        ingredient.quantity.truncateToDouble() == ingredient.quantity ? 0 : 2,
      );
      _unitController.text = ingredient.unit;
    });
  }

  void _addOrUpdateIngredient() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final quantityString = _quantityController.text.trim();
      final unit = _unitController.text.trim();

      double? quantity;
      try {
        quantity = double.parse(quantityString);
        if (quantity <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quantity must be greater than 0'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid quantity format'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userId = _firestoreService.getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: User not found. Please log in first.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        if (_selectedIngredientId == null) {
          final newIngredient = Ingredient(
            name: name,
            quantity: quantity,
            unit: unit,
            userId: userId,
          );
          await _firestoreService.addIngredient(newIngredient);
          Navigator.of(context).pop(); // Tutup loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ingredient added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          if (_selectedIngredientForEdit == null) {
            Navigator.of(context).pop(); // Close loading
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: Ingredient data for editing not found.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          final updatedIngredient = Ingredient(
            id: _selectedIngredientId,
            name: name,
            quantity: quantity,
            unit: unit,
            userId: userId,
            createdAt: _selectedIngredientForEdit!.createdAt,
          );
          await _firestoreService.updateIngredient(updatedIngredient);
          Navigator.of(context).pop(); // Tutup loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ingredient updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _clearForm();
      } catch (e) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteIngredient(String ingredientId) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this ingredient? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        await _firestoreService.deleteIngredient(ingredientId);
        Navigator.of(context).pop(); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ingredient deleted successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        if (_selectedIngredientId == ingredientId) {
          _clearForm();
        }
      } catch (e) {
        Navigator.of(context).pop(); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete ingredient: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIngredientId == null ? 'Add Ingredient' : 'Edit Ingredient',
        ),
        actions: [
          if (_selectedIngredientId != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Cancel Edit',
              onPressed: _clearForm,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- FORM INPUT BAHAN ---
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredient Name',
                      border: OutlineInputBorder(),
                      hintText: 'Example: Soy Sauce',
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingredient name cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      hintText: 'Example: 10 or 0.5',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Quantity cannot be empty';
                      }
                      try {
                        final quantity = double.parse(value.trim());
                        if (quantity <= 0) {
                          return 'Quantity must be greater than 0';
                        }
                      } catch (e) {
                        return 'Invalid quantity format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                      hintText: 'Example: kg, gram, butir, buah, ml',
                      prefixIcon: Icon(
                        Icons.square_foot_outlined,
                      ), // Ganti ikon jika ada yang lebih cocok
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Unit cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, // Tombol selebar layar
                    child: ElevatedButton.icon(
                      icon: Icon(
                        _selectedIngredientId == null ? Icons.add : Icons.save,
                      ),
                      label: Text(
                        _selectedIngredientId == null
                            ? 'Save Bahan'
                            : 'Update Bahan',
                      ),
                      onPressed: _addOrUpdateIngredient,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Your Ingredients List',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            // --- STREAMBUILDER UNTUK MENAMPILKAN DAFTAR BAHAN ---
            StreamBuilder<List<Ingredient>>(
              stream: _firestoreService.getIngredientsStream(),
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'You do not have any ingredients yet. Add some now!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                final ingredients = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true, // Penting di dalam SingleChildScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Agar tidak ada double scroll
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = ingredients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2.0,
                      child: ListTile(
                        leading: Image.network(
                          "https://www.themealdb.com/images/ingredients/${ingredient.name.toLowerCase().replaceAll(' ', '_')}.png",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey,
                            );
                          },
                        ),
                        title: Text(
                          ingredient.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${ingredient.quantity.toStringAsFixed(ingredient.quantity.truncateToDouble() == ingredient.quantity ? 0 : 2)} ${ingredient.unit}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Edit',
                              onPressed: () => _populateFormForEdit(ingredient),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () {
                                if (ingredient.id != null) {
                                  _deleteIngredient(ingredient.id!);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error: Ingredient ID not found for deletion.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () => _populateFormForEdit(
                          ingredient,
                        ), // Bisa juga untuk edit
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
