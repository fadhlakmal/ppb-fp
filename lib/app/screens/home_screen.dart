import 'package:flutter/material.dart';
import 'package:myapp/app/services/meal_api_service.dart';

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
