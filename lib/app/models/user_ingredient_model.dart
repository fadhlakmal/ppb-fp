import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  final String? id;
  final String name;
  final double quantity;
  final String unit;
  final String userId;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String? imageUrl;

  Ingredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
  });


  factory Ingredient.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Ingredient(
      id: snapshot.id,
      name: data?['name'] ?? '',
      quantity: (data?['quantity'] ?? 0).toDouble(),
      unit: data?['unit'] ?? '',
      userId: data?['userId'] ?? '',
      createdAt: data?['createdAt'] as Timestamp?,
      updatedAt: data?['updatedAt'] as Timestamp?,
        imageUrl: data?['imageUrl'] as String?,
    );
  }


  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'userId': userId,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}