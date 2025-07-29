import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../models/auth_models.dart';
import 'login_screen.dart';
import 'main_navigation.dart';

class AuthWrapper extends StatefulWidget {
  final ThemeProvider themeProvider;

  const AuthWrapper({super.key, required this.themeProvider});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isInitializing = true;
  AuthSession? _currentSession;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
    
    // Listen to authentication state changes
    _authService.authStateStream.listen((session) {
      if (mounted) {
        setState(() {
          _currentSession = session;
        });
      }
    });
  }

  Future<void> _initializeAuth() async {
    try {
      await _authService.initialize();
      _currentSession = _authService.currentSession;
    } catch (e) {
      print('🔐 AuthWrapper: Error initializing auth: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing
    if (_isInitializing) {
      return _buildLoadingScreen();
    }

    // Show login screen if not authenticated
    if (_currentSession == null || _currentSession!.isExpired) {
      return LoginScreen(themeProvider: widget.themeProvider);
    }

    // Show main app if authenticated
    return MainNavigation(themeProvider: widget.themeProvider);
  }

  Widget _buildLoadingScreen() {
    return AnimatedBuilder(
      animation: widget.themeProvider,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4F46E5), // Modern indigo
                  const Color(0xFF7C3AED), // Modern purple
                  const Color(0xFF2563EB), // Modern blue
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        'icon.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4F46E5),
                                  Color(0xFF7C3AED),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              CupertinoIcons.drop_fill,
                              size: 50,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Loading indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Smart IoT Master',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Initializing secure connection...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}