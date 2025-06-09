import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/app/models/recipe_schedule_model.dart';
import 'package:myapp/app/services/notification_service.dart';

class RecipeScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  get _scheduledRecipes => _db.collection('scheduled_recipes');

  String? get _uid => _auth.currentUser?.uid;

  Stream<List<RecipeScheduleModel>> getScheduledRecipes() {
    if (_uid == null) {
      return Stream.value(<RecipeScheduleModel>[]);
    }

    return _scheduledRecipes
        .where('uid', isEqualTo: _uid)
        .orderBy('scheduleDateTime')
        .snapshots()
        .map<List<RecipeScheduleModel>>(
          (QuerySnapshot<Map<String, dynamic>> snapshot) =>
              snapshot.docs
                  .map<RecipeScheduleModel>(
                    (doc) => RecipeScheduleModel.fromMap({
                      ...doc.data(),
                      'id': doc.id,
                    }),
                  )
                  .toList(),
        );
  }

  Future<String?> scheduleRecipe(RecipeScheduleModel recipe) async {
    if (_uid == null) return null;

    DocumentReference docRef = await _scheduledRecipes.add({
      ...recipe.toMap(),
      'uid': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (recipe.isActive) {
      await _scheduleRecipeNotification(recipe.copyWith(id: docRef.id));
    }

    return docRef.id;
  }

  Future<void> updateScheduledRecipe(RecipeScheduleModel recipe) async {
    if (_uid == null) return;

    await NotificationService.cancelNotification(recipe.id.hashCode);
    await NotificationService.cancelNotification(recipe.id.hashCode + 10000);

    await _scheduledRecipes.doc(recipe.id.toString()).update({
      'recipeTitle': recipe.recipeTitle,
      'scheduleDateTime': recipe.scheduleDateTime.millisecondsSinceEpoch,
      'reminderMessage': recipe.reminderMessage,
      'isActive': recipe.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (recipe.isActive) {
      await _scheduleRecipeNotification(recipe);
    }
  }

  Future<void> deleteScheduledRecipe(int recipeId) async {
    if (_uid == null) return;

    await _scheduledRecipes.doc(recipeId.toString()).delete();

    await NotificationService.cancelNotification(recipeId.hashCode);
    await NotificationService.cancelNotification(recipeId.hashCode + 10000);
  }

  Future<void> toggleRecipeActive(RecipeScheduleModel recipe) async {
    if (_uid == null) return;

    await _scheduledRecipes.doc(recipe.id.toString()).update({
      'isActive': !recipe.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (recipe.isActive) {
      await NotificationService.cancelNotification(recipe.id.hashCode);
      await NotificationService.cancelNotification(recipe.id.hashCode + 10000);
    } else {
      await _scheduleRecipeNotification(recipe.copyWith(isActive: true));
    }
  }

  Future<void> _scheduleRecipeNotification(RecipeScheduleModel recipe) async {
    final now = DateTime.now();
    final timeUntilScheduled = recipe.scheduleDateTime.difference(now);

    if (timeUntilScheduled.isNegative) return;

    await NotificationService.createNotification(
      id: recipe.id.hashCode,
      title: '👨‍🍳 Recipe Reminder',
      body: 'Time to cook: ${recipe.recipeTitle}',
      summary: recipe.reminderMessage,
      scheduled: true,
      interval: timeUntilScheduled,
      actionButtons: [
        NotificationActionButton(key: 'START_COOKING', label: 'Start Cooking'),
        NotificationActionButton(key: 'SNOOZE', label: 'Snooze 10min'),
      ],
    );

    if (timeUntilScheduled.inMinutes > 30) {
      await NotificationService.createNotification(
        id: recipe.id.hashCode + 10000,
        title: '🔔 Upcoming Recipe',
        body: '${recipe.recipeTitle} - in 30 minutes',
        summary: 'Get ready to start cooking!',
        scheduled: true,
        interval: timeUntilScheduled - const Duration(minutes: 30),
      );
    }
  }

  Future<void> snoozeRecipe(int recipeId, Duration snoozeDuration) async {
    await NotificationService.createNotification(
      id: recipeId.hashCode + 20000,
      title: '👨‍🍳 Recipe Reminder (Snoozed)',
      body: 'Time to cook your recipe!',
      scheduled: true,
      interval: snoozeDuration,
    );
  }

  Future<void> markRecipeAsCooked(int recipeId, String recipeTitle) async {
    await NotificationService.cancelNotification(recipeId.hashCode);
    await NotificationService.cancelNotification(recipeId.hashCode + 10000);
    await NotificationService.cancelNotification(recipeId.hashCode + 20000);

    await NotificationService.createNotification(
      id: 30000 + recipeId.hashCode,
      title: 'Recipe Completed! 🍽️',
      body: 'Great job cooking: $recipeTitle',
    );
  }
}
