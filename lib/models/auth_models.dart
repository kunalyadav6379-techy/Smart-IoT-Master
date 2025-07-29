class User {
  final String username;
  final String email;
  final String role;
  final String? lastLogin;

  User({
    required this.username,
    required this.email,
    required this.role,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      lastLogin: json['last_login'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'role': role,
      'last_login': lastLogin,
    };
  }
}

class LoginResponse {
  final bool success;
  final String? token;
  final User? user;
  final String? expiresAt;
  final String? message;

  LoginResponse({
    required this.success,
    this.token,
    this.user,
    this.expiresAt,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      token: json['token'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      expiresAt: json['expires_at'] as String?,
      message: json['message'] as String?,
    );
  }
}

class AuthSession {
  final String token;
  final User user;
  final String expiresAt;

  AuthSession({
    required this.token,
    required this.user,
    required this.expiresAt,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      user: User.fromJson(json['user']),
      expiresAt: json['expires_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'expires_at': expiresAt,
    };
  }

  bool get isExpired {
    try {
      final expiryDate = DateTime.parse(expiresAt);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }
}