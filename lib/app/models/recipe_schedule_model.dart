import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeScheduleModel {
  final String id;
  final String recipeId;
  final String recipeTitle;
  final DateTime scheduleDateTime;
  final String reminderMessage;
  final bool isActive;

  RecipeScheduleModel({
    this.id = '',
    required this.recipeId,
    required this.recipeTitle,
    required this.scheduleDateTime,
    required this.reminderMessage,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      'scheduleDateTime': Timestamp.fromDate(scheduleDateTime),
      'reminderMessage': reminderMessage,
      'isActive': isActive,
    };
  }

  factory RecipeScheduleModel.fromMap(Map<String, dynamic> map) {
    return RecipeScheduleModel(
      id: map['id'] ?? '',
      recipeId: map['recipeId'] ?? '',
      recipeTitle: map['recipeTitle'] ?? '',
      scheduleDateTime:
          map['scheduleDateTime'] is Timestamp
              ? (map['scheduleDateTime'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(
                map['scheduleDateTime'] ?? 0,
              ),
      reminderMessage: map['reminderMessage'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  RecipeScheduleModel copyWith({
    String? id,
    String? recipeId,
    String? recipeTitle,
    DateTime? scheduleDateTime,
    String? reminderMessage,
    bool? isActive,
  }) {
    return RecipeScheduleModel(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      scheduleDateTime: scheduleDateTime ?? this.scheduleDateTime,
      reminderMessage: reminderMessage ?? this.reminderMessage,
      isActive: isActive ?? this.isActive,
    );
  }
}
