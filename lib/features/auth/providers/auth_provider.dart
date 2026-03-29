import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/auth_models.dart';
import '../services/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiService? apiService})
    : _authRepository = AuthRepository(apiService: apiService);
  User? _user;
  String? _token;
  bool _isLoading = false;

  final AuthRepository _authRepository;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<void> init() async {
    _token = await _authRepository.getToken();
    _user = await _authRepository.getCurrentUser();
    notifyListeners();
  }

  Future<AuthResponse> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authResponse = await _authRepository.login(email, password);

      if (authResponse.success && authResponse.token != null) {
        _token = authResponse.token;
        _user = authResponse.user;
      }

      _isLoading = false;
      notifyListeners();
      return authResponse;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AuthResponse(success: false, message: e.toString());
    }
  }

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authResponse = await _authRepository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );

      if (authResponse.success && authResponse.token != null) {
        _token = authResponse.token;
        _user = authResponse.user;
      }

      _isLoading = false;
      notifyListeners();
      return authResponse;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AuthResponse(success: false, message: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      _token = null;
      _user = null;
      notifyListeners();
    } catch (e) {
      // Handle logout error if needed
      notifyListeners();
    }
  }

  void forceLogout() {
    _token = null;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> checkEmailExists(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authRepository.checkEmailExists(email);
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<AuthResponse> changePassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authRepository.changePassword(email, password);
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AuthResponse(success: false, message: e.toString());
    }
  }
}
