import 'package:flutter/material.dart';
import 'package:myapp/app/screens/home_screen.dart';
import 'package:myapp/app/screens/profile_screen.dart';
import 'package:myapp/app/screens/add_ingredient_screen.dart';
import 'package:myapp/app/screens/recipe_schedule_screen.dart';
import 'package:myapp/app/widgets/bottom_navbar_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    AddIngredientScreen(),
    ScheduleScreen(),
    ProfileScreen(),
  ];

  void onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavbarWidget(
        onTap: onTabSelected,
        currentIndex: _currentIndex,
      ),
    );
  }
}
