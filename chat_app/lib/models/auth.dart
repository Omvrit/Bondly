class User {
  final String id;
  final String username;
  final String email;
  final String avatar;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  
  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });
  
  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}

class AuthResponse {
  final User user;
  final AuthTokens tokens;
  
  AuthResponse({
    required this.user,
    required this.tokens,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      tokens: AuthTokens.fromJson(json['tokens']),
    );
  }
}