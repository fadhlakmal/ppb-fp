import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app/services/meal_api_service.dart';
import 'package:myapp/app/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MealApiService _mealApiService = MealApiService();
  String _text = "Hello";

  Future<void> _getRandomMeal() async {
    final response = await _mealApiService.getRandomMeal();
    if (response.success) {
      setState(() {
        _text = response.data!.strMeal;
      });
    } else {
      print(response.error);
    }
  }

  Future<void> _testImmediateNotification() async {
    try {
      await NotificationService.showImmediateNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: "Tes Langsung",
        body: "Langsung masak",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification sent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Notification error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testScheduledNotification() async {
    try {
      await NotificationService.scheduleRecipeReminder(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        recipeTitle: "Test Tunggu",
        scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
        body: "Tunggu masak",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Notification scheduled for 5 sec"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Notification error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(_text)),
      floatingActionButton: ElevatedButton(
        onPressed: _getRandomMeal,
        child: Icon(Icons.add),
      ),
    );
  }
}
