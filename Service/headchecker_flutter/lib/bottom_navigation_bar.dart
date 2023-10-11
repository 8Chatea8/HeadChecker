import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      backgroundColor: colorScheme.onPrimaryContainer,
      unselectedItemColor: colorScheme.secondary,
      selectedItemColor: colorScheme.onPrimary,
      unselectedFontSize: 10,
      selectedFontSize: 12,
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
        BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'NEWS'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'CHECK'),
      ],
    );
  }
}
