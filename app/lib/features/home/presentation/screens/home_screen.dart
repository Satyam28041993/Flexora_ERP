import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/app_nav_model.dart';
import '../widgets/app_sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  /// Screens are built lazily and cached, so switching back to a destination
  /// does not rebuild it from scratch (and does not re-hit Firestore).
  final Map<int, Widget> _pageCache = {};

  Widget _pageFor(int index) =>
      _pageCache[index] ??= AppNavigation.flatItems[index].builder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
          ),
          const VerticalDivider(thickness: 1, width: 1, color: AppTheme.border),
          Expanded(child: _pageFor(_selectedIndex)),
        ],
      ),
    );
  }
}
