import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String baseUrl = 'http://1.1.1.1:5001';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _sessionKey = 'auth_session';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AuthSession? _currentSession;
  final StreamController<AuthSession?> _authStateController = 
      StreamController<AuthSession?>.broadcast();

  Stream<AuthSession?> get authStateStream => _authStateController.stream;
  AuthSession? get currentSession => _currentSession;
  bool get isLoggedIn => _currentSession != null && !_currentSession!.isExpired;

  /// Initialize authentication service and check for existing session
  Future<void> initialize() async {
    try {
      print('🔐 AuthService: Initializing...');
      await _loadStoredSession();
      
      if (_currentSession != null) {
        // Validate stored session with server
        final isValid = await _validateStoredSession();
        if (!isValid) {
          await logout();
        }
      }
      
      print('🔐 AuthService: Initialized. Logged in: $isLoggedIn');
    } catch (e) {
      print('🔐 AuthService: Error during initialization: $e');
      await logout(); // Clear any corrupted data
    }
  }

  /// Load stored session from SharedPreferences
  Future<void> _loadStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      
      if (sessionJson != null) {
        final sessionData = json.decode(sessionJson);
        _currentSession = AuthSession.fromJson(sessionData);
        _authStateController.add(_currentSession);
        print('🔐 AuthService: Loaded stored session for ${_currentSession!.user.username}');
      }
    } catch (e) {
      print('🔐 AuthService: Error loading stored session: $e');
      _currentSession = null;
      _authStateController.add(null);
    }
  }

  /// Validate stored session with server
  Future<bool> _validateStoredSession() async {
    if (_currentSession == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_currentSession!.token}',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['valid'] == true;
      }
      
      return false;
    } catch (e) {
      print('🔐 AuthService: Error validating session: $e');
      return false;
    }
  }

  /// Login with username and password
  Future<LoginResponse> login(String username, String password) async {
    try {
      print('🔐 AuthService: Attempting login for $username');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final loginResponse = LoginResponse.fromJson(json.decode(response.body));

      if (loginResponse.success && loginResponse.token != null && loginResponse.user != null) {
        // Store session
        _currentSession = AuthSession(
          token: loginResponse.token!,
          user: loginResponse.user!,
          expiresAt: loginResponse.expiresAt!,
        );

        await _storeSession(_currentSession!);
        _authStateController.add(_currentSession);
        
        print('🔐 AuthService: Login successful for ${loginResponse.user!.username}');
      } else {
        print('🔐 AuthService: Login failed - ${loginResponse.message}');
      }

      return loginResponse;
    } catch (e) {
      print('🔐 AuthService: Login error: $e');
      return LoginResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Store session in SharedPreferences
  Future<void> _storeSession(AuthSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, json.encode(session.toJson()));
      await prefs.setString(_tokenKey, session.token);
      await prefs.setString(_userKey, json.encode(session.user.toJson()));
      
      print('🔐 AuthService: Session stored successfully');
    } catch (e) {
      print('🔐 AuthService: Error storing session: $e');
    }
  }

  /// Logout user and clear stored data
  Future<bool> logout() async {
    try {
      print('🔐 AuthService: Logging out...');
      
      // Notify server about logout
      if (_currentSession != null) {
        try {
          await http.post(
            Uri.parse('$baseUrl/api/auth/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${_currentSession!.token}',
            },
          ).timeout(const Duration(seconds: 5));
        } catch (e) {
          print('🔐 AuthService: Error notifying server about logout: $e');
        }
      }

      // Clear local data
      await _clearStoredData();
      _currentSession = null;
      _authStateController.add(null);
      
      print('🔐 AuthService: Logout completed');
      return true;
    } catch (e) {
      print('🔐 AuthService: Error during logout: $e');
      return false;
    }
  }

  /// Clear all stored authentication data
  Future<void> _clearStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      print('🔐 AuthService: Error clearing stored data: $e');
    }
  }

  /// Get current user info from server
  Future<User?> getCurrentUser() async {
    if (_currentSession == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_currentSession!.token}',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return User.fromJson(data['user']);
        }
      }
      
      return null;
    } catch (e) {
      print('🔐 AuthService: Error getting current user: $e');
      return null;
    }
  }

  /// Check if current session is valid
  Future<bool> isSessionValid() async {
    if (_currentSession == null || _currentSession!.isExpired) {
      return false;
    }

    return await _validateStoredSession();
  }

  /// Get authorization header for API requests
  String? getAuthHeader() {
    if (_currentSession != null) {
      return 'Bearer ${_currentSession!.token}';
    }
    return null;
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}