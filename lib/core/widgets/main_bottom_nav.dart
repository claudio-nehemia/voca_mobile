import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../../features/vocabulary/presentation/screens/themes_screen.dart';
import '../../features/home/presentation/screens/exercises_screen.dart';
import '../../features/home/presentation/screens/profile_screen.dart';

class MainBottomNav extends StatelessWidget {
  final int selectedIndex;
  
  const MainBottomNav({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) async {
        // Handle navigation or switching
        if (index == 0 && selectedIndex != 0) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (index == 1 && selectedIndex != 1) {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => ThemesScreen()));
        } else if (index == 2 && selectedIndex != 2) {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ExercisesScreen()));
        } else if (index == 3 && selectedIndex != 3) {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.lightTextColor,
      backgroundColor: Colors.white,
      elevation: 10,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Vocabulary'),
        BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), activeIcon: Icon(Icons.edit_note), label: 'Exercises'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
