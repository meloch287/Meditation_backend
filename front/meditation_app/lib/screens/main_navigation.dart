import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/glass_container.dart';
import 'home_screen.dart';
import 'meditation_screen.dart';
import 'psychologist_screen.dart';
import 'profile_screen.dart';
import 'subscription_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MeditationScreen(),
    const PsychologistScreen(),
    const ProfileScreen(),
    const SubscriptionScreen(),
  ];

  final List<String> _titles = [
    'Главная',
    'Медитации',
    'Психолог',
    'Профиль',
    'Подписка',
  ];

  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.self_improvement,
    Icons.psychology_outlined,
    Icons.person_outline,
    Icons.star_outline,
  ];

  final List<IconData> _selectedIcons = [
    Icons.home,
    Icons.self_improvement,
    Icons.psychology,
    Icons.person,
    Icons.star,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.95),
            ],
          ),
        ),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          opacity: 0.1,
          borderRadius: BorderRadius.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _screens.length,
              (index) => _buildNavItem(
                index: index,
                icon: _currentIndex == index ? _selectedIcons[index] : _icons[index],
                label: _titles[index],
                isSelected: _currentIndex == index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}