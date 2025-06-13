import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  String? id;
  String name;
  String category;
  String area;
  String instructions;
  String imageUrl;
  String userId;
  List<String> ingredients;
  List<String> measurements;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  Recipe({
    this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.imageUrl,
    required this.userId,
    required this.ingredients,
    required this.measurements,
    this.createdAt,
    this.updatedAt,
  });

  factory Recipe.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Recipe(
      id: snapshot.id,
      name: data?['name'] ?? '',
      category: data?['category'] ?? '',
      area: data?['area'] ?? '',
      instructions: data?['instructions'] ?? '',
      imageUrl: data?['imageUrl'] ?? '',
      userId: data?['userId'] ?? '',
      ingredients: List<String>.from(data?['ingredients'] ?? []),
      measurements: List<String>.from(data?['measurements'] ?? []),
      createdAt: data?['createdAt'] as Timestamp?,
      updatedAt: data?['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'area': area,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'userId': userId,
      'ingredients': ingredients,
      'measurements': measurements,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  Future<void> save() async {
    final collection = FirebaseFirestore.instance.collection('recipes');
    if (id != null) {
      updatedAt = Timestamp.now();
      await collection.doc(id).set(toFirestore(), SetOptions(merge: true));
    } else {
      createdAt = Timestamp.now();
      updatedAt = createdAt;
      final docRef = await collection.add(toFirestore());
      id = docRef.id;
    }
  }
}
