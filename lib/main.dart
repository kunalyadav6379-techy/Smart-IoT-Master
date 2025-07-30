import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_wrapper.dart';

void main() {
  runApp(const WaterTankApp());
}

class WaterTankApp extends StatefulWidget {
  const WaterTankApp({super.key});

  @override
  State<WaterTankApp> createState() => _WaterTankAppState();
}

class _WaterTankAppState extends State<WaterTankApp> {
  late ThemeProvider _themeProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeProvider();
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    await _themeProvider.initializeTheme();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4F46E5), // Modern indigo
                  Color(0xFF7C3AED), // Modern purple
                  Color(0xFF2563EB), // Modern blue
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    return AnimatedBuilder(
      animation: _themeProvider,
      builder: (context, child) {
        return MaterialApp(
          title: 'IoT Monitor',
          theme: ThemeData(
            brightness: _themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: _themeProvider.backgroundColor,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: _themeProvider.textColor),
              bodyMedium: TextStyle(color: _themeProvider.textColor),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: _themeProvider.backgroundColor,
              foregroundColor: _themeProvider.textColor,
            ),
          ),
          home: AuthWrapper(themeProvider: _themeProvider),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}