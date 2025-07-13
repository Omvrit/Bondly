import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/connection_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  AuthTokens? _tokens;
  bool _isLoading = false;
  String? _error;
  Timer? _tokenRefreshTimer;
  List<User> _connections = [];
  bool _connectionsLoading = false;
  String? _connectionsError;

  User? get user => _user;
  AuthTokens? get tokens => _tokens;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _tokens != null;
  List<User> get connections => _connections;
  bool get connectionsLoading => _connectionsLoading;
  String? get connectionsError => _connectionsError;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Try to get saved tokens and user
      final savedTokens = await AuthService.getTokens();
      final savedUser = await AuthService.getUser();
      
      if (savedTokens != null && savedUser != null) {
        _tokens = savedTokens;
        _user = savedUser;
        _startTokenRefreshTimer();
        await _loadConnections(); // Load connections after auth
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Auth init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadConnections() async {
    if (_tokens == null) return;
    
    _connectionsLoading = true;
    _connectionsError = null;
    notifyListeners();
    
    try {
      final connectionService = ConnectionService(
        baseUrl: 'http://192.168.150.102:5000',
        authToken: _tokens!.accessToken,
      );
      _connections = await connectionService.getConnections();
      _connectionsError = null;
    } catch (e) {
      _connectionsError = e.toString();
      if (kDebugMode) print('Failed to load connections: $e');
    } finally {
      _connectionsLoading = false;
      notifyListeners();
    }
  }

  Future<void> addConnection(String userId) async {
    if (_tokens == null) return;
    
    _connectionsLoading = true;
    notifyListeners();
    
    try {
      final connectionService = ConnectionService(
        baseUrl: 'http://192.168.150.102:5000/',
        authToken: _tokens!.accessToken,
      );
      await connectionService.addConnection(userId);
      await _loadConnections(); // Refresh connections after adding
    } catch (e) {
      _connectionsError = e.toString();
      if (kDebugMode) print('Failed to add connection: $e');
      rethrow;
    } finally {
      _connectionsLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await AuthService().register(username, email, password);
      _user = response.user;
      _tokens = response.tokens;
      
      await AuthService.saveTokens(response.tokens);
      await AuthService.saveUser(response.user);
      
      _startTokenRefreshTimer();
      await _loadConnections(); // Load connections after registration
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    print("email: $email, password: $password");
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await AuthService().login(email, password);
      _user = response.user;
      _tokens = response.tokens;
      
      await AuthService.saveTokens(response.tokens);
      await AuthService.saveUser(response.user);
      
      _startTokenRefreshTimer();
      // await _loadConnections(); // Load connections after login
    } catch (e) {
      _error = "Error message:"+e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_tokens != null) {
      try {
        await AuthService().logout(_tokens!.accessToken);
      } catch (e) {
        if (kDebugMode) print('Logout error: $e');
      }
    }
    
    // Clear all data
    _user = null;
    _tokens = null;
    _connections.clear();
    _tokenRefreshTimer?.cancel();
    
    await AuthService.clearAuthData();
    
    notifyListeners();
  }

  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    // Refresh token 1 minute before expiration (14 minutes)
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 14), (timer) async {
      if (_tokens?.refreshToken == null) return;
      
      try {
        final newTokens = await AuthService().refreshToken(_tokens!.refreshToken);
        _tokens = newTokens;
        await AuthService.saveTokens(newTokens);
        notifyListeners();
      } catch (e) {
        if (kDebugMode) print('Token refresh failed: $e');
        logout();
      }
    });
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }
}