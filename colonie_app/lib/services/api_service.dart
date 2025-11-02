import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/user_type.dart';

class ApiService {
  static const String baseUrl = 'http://72.61.161.87:8080';
  static const String apiPath = '/api';

  static const Duration timeout = Duration(seconds: 30);

  final http.Client _client = http.Client();

  // Keys pour stockage local
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // Getters pour les tokens
  Future<String?> get accessToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> get refreshToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<User?> get currentUser async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Authentification
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserType userType,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl$apiPath/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'firstName': firstName,
              'lastName': lastName,
              'userType': userType.name,
            }),
          )
          .timeout(timeout);

      return _handleAuthResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl$apiPath/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(timeout);

      return _handleAuthResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> _refreshAuthToken() async {
    try {
      final refresh = await refreshToken;
      if (refresh == null) {
        throw Exception('No refresh token available');
      }

      final response = await _client
          .post(
            Uri.parse('$baseUrl$apiPath/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'refreshToken': refresh,
            }),
          )
          .timeout(timeout);

      return _handleAuthResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      final token = await accessToken;
      if (token != null) {
        await _client
            .post(
              Uri.parse('$baseUrl$apiPath/auth/logout'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(timeout);
      }
    } catch (e) {
      // Pas d'erreur critique si logout échoue côté serveur
      print('Logout error: $e');
    } finally {
      await _clearTokens();
    }
  }

  // Requêtes HTTP avec authentification automatique
  Future<http.Response> get(String endpoint) async {
    return _makeRequest('GET', endpoint);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    return _makeRequest('POST', endpoint, body: body);
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    return _makeRequest('PUT', endpoint, body: body);
  }

  Future<http.Response> delete(String endpoint) async {
    return _makeRequest('DELETE', endpoint);
  }

  // Upload de fichiers
  Future<http.Response> uploadFile(
    String endpoint,
    File file,
    String fieldName, {
    Map<String, String>? fields,
  }) async {
    try {
      final token = await accessToken;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$apiPath$endpoint'),
      );

      // Ajouter le fichier
      final fileBytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        fieldName,
        fileBytes,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Ajouter les champs additionnels
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Ajouter headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Méthodes privées
  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    int retryCount = 1,
  }) async {
    try {
      final token = await accessToken;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final Uri uri = Uri.parse('$baseUrl$apiPath$endpoint');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      late http.Response response;

      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers).timeout(timeout);
          break;
        case 'POST':
          response = await _client
              .post(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeout);
          break;
        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: headers).timeout(timeout);
          break;
        default:
          throw Exception('Unsupported method: $method');
      }

      // Gérer le 401 (token expiré)
      if (response.statusCode == 401 && retryCount > 0) {
        try {
          await _refreshTokenAndSave();
          return _makeRequest(method, endpoint, body: body, retryCount: retryCount - 1);
        } catch (e) {
          // Le refresh a échoué, on déconnecte l'utilisateur
          await _clearTokens();
          throw Exception('Session expired. Please login again.');
        }
      }

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> _handleAuthResponse(http.Response response) async {
    final responseBody = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final authResponse = AuthResponse.fromJson(responseBody);

      // Sauvegarder les tokens
      await _saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
        authResponse.user,
      );

      return authResponse;
    } else {
      // Gérer différents formats d'erreur
      String errorMessage = 'Authentication failed';

      if (responseBody['error'] != null) {
        errorMessage = responseBody['error']['message'] ??
                       responseBody['error'] ??
                       'Authentication error';
      } else if (responseBody['message'] != null) {
        errorMessage = responseBody['message'];
      }

      throw Exception(errorMessage);
    }
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      try {
        final responseBody = jsonDecode(response.body);
        throw Exception(
          responseBody['error']['message'] ??
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      } catch (e) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    }
  }

  Future<void> _refreshTokenAndSave() async {
    final authResponse = await _refreshAuthToken();
    await _saveTokens(
      authResponse.accessToken,
      authResponse.refreshToken,
      authResponse.user,
    );
  }

  Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
    User user,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }

  Exception _handleError(dynamic error) {
    if (error is SocketException) {
      return Exception('No internet connection');
    } else if (error is HttpException) {
      return Exception('HTTP Error: ${error.message}');
    } else if (error is FormatException) {
      return Exception('Invalid response format');
    } else {
      return Exception(error.toString());
    }
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl$apiPath/health'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// Modèles de réponse
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    // Gérer les deux formats de réponse API
    final tokens = data['tokens'] as Map<String, dynamic>? ?? data;

    return AuthResponse(
      accessToken: tokens['accessToken'],
      refreshToken: tokens['refreshToken'],
      user: User.fromJson(data['user']),
    );
  }
}

class ApiResponse {
  final bool success;
  final dynamic data;
  final String message;
  final DateTime timestamp;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}