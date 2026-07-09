import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellScreen extends StatelessWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/trip')) return 1;
    if (location.startsWith('/history')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final unselected = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.4);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex(context),
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/trip');
                break;
              case 2:
                context.go('/history');
                break;
              case 3:
                context.go('/profile');
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus_outlined, color: unselected),
              activeIcon: Icon(
                Icons.directions_bus_filled_outlined,
                color: accent,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline, color: unselected),
              activeIcon: Icon(Icons.play_circle_rounded, color: accent),
              label: 'Tripe',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined, color: unselected),
              activeIcon: Icon(Icons.history_rounded, color: accent),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, color: unselected),
              activeIcon: Icon(Icons.person_rounded, color: accent),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
