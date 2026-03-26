import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/device_service.dart';
import '../../../core/storage/preference_service.dart';
import '../../home/providers/home_provider.dart';
import '../models/auth_models.dart';

class AuthRepository {
  AuthRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();
  final ApiService _apiService;

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.success && authResponse.token != null) {
        final deviceDetails = await DeviceService.getDeviceData();
        await _apiService.post(
          ApiConstants.addDevice,
          data: deviceDetails,
          options: Options(
            headers: {'Authorization': 'Bearer ${authResponse.token!}'},
          ),
        );

        await PreferenceService.saveToken(authResponse.token!);
        if (authResponse.user != null) {
          await PreferenceService.saveUserData(
            authResponse.user!.toJsonString(),
          );
        }
      }

      return authResponse;
    } on Exception {
      rethrow;
    }
  }

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.success && authResponse.token != null) {
        await PreferenceService.saveToken(authResponse.token!);
        if (authResponse.user != null) {
          await PreferenceService.saveUserData(
            authResponse.user!.toJsonString(),
          );
        }
      }

      return authResponse;
    } on Exception {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await HomeProvider().logoutDevice();
      await PreferenceService.clearAuth();
    } on Exception {
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final userDataJson = await PreferenceService.getUserData();
      return userDataJson != null ? User.fromJsonString(userDataJson) : null;
    } on Exception {
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      return await PreferenceService.getToken();
    } on Exception {
      rethrow;
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      final token = await getToken();
      return token != null;
    } on Exception {
      return false;
    }
  }

  Future<Map<String, dynamic>> checkEmailExists(String email) async {
    try {
      final response = await _apiService.post(
        ApiConstants.checkEmailExists,
        data: {'email': email},
      );
      return response.data as Map<String, dynamic>;
    } on Exception {
      rethrow;
    }
  }

  Future<AuthResponse> changePassword(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.changePassword,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      return AuthResponse.fromJson(data);
    } on Exception {
      rethrow;
    }
  }
}
