import 'package:flutter/material.dart';
import 'package:myapp/app/models/recipe_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback delete;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.delete,
  });

  @override
  State<RecipeDetailScreen> createState() => _DetailPageState();
}

class _DetailPageState extends State<RecipeDetailScreen> {
  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController areaController;
  late TextEditingController instructionController;
  List<TextEditingController> ingredientControllers = [];
  List<TextEditingController> measurementControllers = [];

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.recipe.name);
    categoryController = TextEditingController(text: widget.recipe.category);
    areaController = TextEditingController(text: widget.recipe.area);
    instructionController = TextEditingController(
      text: widget.recipe.instructions,
    );
    ingredientControllers = widget.recipe.ingredients
        .map((ingredient) => TextEditingController(text: ingredient))
        .toList();
    measurementControllers = widget.recipe.measurements
        .map((measurement) => TextEditingController(text: measurement))
        .toList();
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    areaController.dispose();
    instructionController.dispose();
    for (var c in ingredientControllers) {
      c.dispose();
    }
    for (var c in measurementControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => isEditing = !isEditing);
  }

  void _saveChanges() async {
    widget.recipe.name = nameController.text;
    widget.recipe.category = categoryController.text;
    widget.recipe.area = areaController.text;
    widget.recipe.instructions = instructionController.text;

    widget.recipe.ingredients = ingredientControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    widget.recipe.measurements = measurementControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    widget.recipe.save();

    setState(() => isEditing = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Changes saved.")));
  }

  void _confirmAndDelete() async {
    final isDeleting = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Recipe'),
        content: Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (isDeleting == true) {
      widget.delete();
      Navigator.pop(context);
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    TextInputType type, {
    int? minLines,
    int? maxLines,
  }) {
    if (!isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              controller.text.isNotEmpty ? controller.text : '-',
              style: TextStyle(fontSize: 16),
            ),
            Divider(color: Colors.transparent),
          ],
        ),
      );
    }

    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: type,
      minLines: minLines,
      maxLines: maxLines,
    );
  }

  Widget _buildIngredientMeasurementFields() {
    final List<Widget> rows = [];

    for (int i = 0; i < ingredientControllers.length; i++) {
      final ingredient = ingredientControllers[i];
      final measurement = i < measurementControllers.length
          ? measurementControllers[i]
          : TextEditingController(); // fallback just in case

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: isEditing
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ingredient,
                        decoration: InputDecoration(
                          labelText: 'Ingredient ${i + 1}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: measurement,
                        decoration: InputDecoration(
                          labelText: 'Measurement ${i + 1}',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          ingredientControllers.removeAt(i);
                          measurementControllers.removeAt(i);
                        });
                      },
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Text(
                        ingredient.text.isNotEmpty ? ingredient.text : '-',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        measurement.text.isNotEmpty ? measurement.text : '-',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    if (isEditing) {
      rows.add(
        TextButton.icon(
          onPressed: () {
            setState(() {
              ingredientControllers.add(TextEditingController());
              measurementControllers.add(TextEditingController());
            });
          },
          icon: Icon(Icons.add),
          label: Text("Add Ingredient"),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ingredients & Measurements",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Recipe" : "Recipe Details"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              _confirmAndDelete();
            },
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _saveChanges();
              } else {
                _toggleEdit();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!isEditing && widget.recipe.imageUrl.isNotEmpty)
              Image.network(widget.recipe.imageUrl),
            _buildTextField("Name", nameController, TextInputType.name),
            _buildTextField("Category", categoryController, TextInputType.text),
            _buildTextField("Area", areaController, TextInputType.text),
            _buildTextField(
              "Instructions",
              instructionController,
              TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            _buildIngredientMeasurementFields(),
          ],
        ),
      ),
    );
  }
}
