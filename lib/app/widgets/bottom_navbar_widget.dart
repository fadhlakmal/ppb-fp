import 'package:flutter/material.dart';

class BottomNavbarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbarWidget({
    super.key,
    required this.onTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.set_meal_outlined),
          label: "Bahan",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Schedule"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
