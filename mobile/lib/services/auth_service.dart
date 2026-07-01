import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class AuthService {
  // Use localhost for Web, 192.168.88.43 for Android emulator
  final String baseUrl = kIsWeb ? 'https://groupprojet-production.up.railway.app/api/auth' : 'https://groupprojet-production.up.railway.app/api/auth';

  static String? _mockSecureStorageToken;
  static UserModel? _currentUser;

  // Singleton pattern to access currentUser globally easily for this demo
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // --- Login ---
  Future<UserModel> login(String emailOrUsername, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': emailOrUsername,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 30)); // Increased timeout to 10s for stability

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String token = data['token'];

      // Stocker le token
      _mockSecureStorageToken = token;
      _currentUser = UserModel.fromJson(data['user']);

      return _currentUser!;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Identifiant ou mot de passe incorrect.');
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // --- Register ---
  Future<UserModel> register(UserModel user, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...user.toJson(),
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String token = data['token'];

        // Stocker le token
        _mockSecureStorageToken = token;
        _currentUser = UserModel.fromJson(data['user']);

        return _currentUser!;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<UserModel> socialLogin({
    required String provider,
    required String email,
    String? firstName,
    String? lastName,
    String? providerId,
    String? profileImage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/social-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': provider,
          'providerId': providerId ?? email,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'profileImage': profileImage,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _mockSecureStorageToken = data['token'];
        _currentUser = UserModel.fromJson(data['user']);
        return _currentUser!;
      }

      throw Exception(_messageFromResponse(response));
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // --- Logout ---
  Future<void> logout() async {
    _mockSecureStorageToken = null;
    _currentUser = null;
  }

  // --- Check if authenticated ---
  Future<bool> isAuthenticated() async {
    return _mockSecureStorageToken != null;
  }

  // --- Get Token ---
  Future<String?> getToken() async {
    return _mockSecureStorageToken;
  }

  // --- Get Current User ---
  UserModel? get currentUser => _currentUser;

  String _messageFromResponse(http.Response response) {
    if (response.body.isEmpty) {
      return 'Server error: ${response.statusCode}';
    }
    try {
      final data = jsonDecode(response.body);
      return data['message']?.toString() ?? data['error']?.toString() ?? 'Server error: ${response.statusCode}';
    } catch (_) {
      return 'Server error: ${response.statusCode}';
    }
  }
}
