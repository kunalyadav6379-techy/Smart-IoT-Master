import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../providers/theme_provider.dart';
import 'water_tank_screen.dart';
import 'system_screen.dart';
import 'debug_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  final ThemeProvider themeProvider;

  const MainNavigation({super.key, required this.themeProvider});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late PageController _pageController;

  late final List<Widget> _screens;

  final List<NavigationItem> _navItems = [
    NavigationItem(
      icon: CupertinoIcons.home,
      label: 'Home',
      color: Colors.blue,
    ),
    NavigationItem(
      icon: CupertinoIcons.gear_alt,
      label: 'System',
      color: Colors.green,
    ),
    NavigationItem(
      icon: CupertinoIcons.wrench,
      label: 'Debug',
      color: Colors.orange,
    ),
    NavigationItem(
      icon: CupertinoIcons.settings,
      label: 'Settings',
      color: Colors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      WaterTankScreen(themeProvider: widget.themeProvider),
      SystemScreen(themeProvider: widget.themeProvider),
      DebugScreen(themeProvider: widget.themeProvider),
      SettingsScreen(themeProvider: widget.themeProvider),
    ];
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        height: 60,
        decoration: BoxDecoration(
          color: widget.themeProvider.navigationBarColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: widget.themeProvider.navigationBorderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 25,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_navItems.length, (index) {
              final isSelected = index == _currentIndex;
              final item = _navItems[index];

              return GestureDetector(
                onTap: () => _onItemTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  constraints: BoxConstraints(
                    maxWidth: isSelected ? 120 : 52, // Limit max width
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected
                        ? 12
                        : 8, // Adjust padding based on state
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? item.color.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    border: isSelected
                        ? Border.all(
                            color: item.color.withValues(alpha: 0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : item.color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: item.color.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            item.icon,
                            color: isSelected
                                ? item.color
                                : widget.themeProvider.isDarkMode
                                ? Colors.white
                                : item.color,
                            size: 20,
                          ),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6), // Reduced spacing
                        Flexible(
                          // Make text flexible to prevent overflow
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _animation.value,
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: item.color,
                                    fontSize: 13, // Slightly smaller font
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow:
                                      TextOverflow.ellipsis, // Handle overflow
                                  maxLines: 1,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
