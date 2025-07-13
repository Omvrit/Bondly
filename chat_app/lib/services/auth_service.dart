import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../services/socket_io_service.dart';

class AuthService {
  static const String baseUrl = "http://192.168.200.102:5000";
  
  Future<AuthResponse> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 201) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(json.decode(response.body)['error'] ?? 'Registration failed');
    }
  }
  
  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(json.decode(response.body)['error'] ?? 'Login failed');
    }
  }
  
  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode != 200) {
      throw Exception('Logout failed');
    }
  }
  
  Future<User> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body)['user']);
    } else {
      throw Exception('Failed to get user data');
    }
  }
  
  Future<AuthTokens> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': refreshToken}),
    );
    
    if (response.statusCode == 200) {
      return AuthTokens.fromJson(json.decode(response.body));
    } else {
      throw Exception('Token refresh failed');
    }
  }
  
  // Save tokens to SharedPreferences
  static Future<void> saveTokens(AuthTokens tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', tokens.accessToken);
    await prefs.setString('refresh_token', tokens.refreshToken);
  }
  
  // Get tokens from SharedPreferences
  static Future<AuthTokens?> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');
    
    if (accessToken != null && refreshToken != null) {
      return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
    }
    return null;
  }
  
  // Save user data to SharedPreferences
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode({
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'avatar': user.avatar,
    }));
  }
  
  // Get user data from SharedPreferences
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    
    if (userString != null) {
      return User.fromJson(json.decode(userString));
    }
    return null;
  }
  
  // Clear authentication data
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
  }
}