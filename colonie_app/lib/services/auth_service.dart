import 'dart:convert';
import '../models/user.dart';
import '../models/user_type.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Getters
  User? get currentUser => null; // Sera géré par ApiService
  Stream<User?> get authStateChanges => Stream.empty(); // Sera implémenté plus tard

  // Inscription
  Future<User> registerWithEmailPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    UserType userType,
  ) async {
    try {
      final response = await _apiService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        userType: userType,
      );

      return response.user;
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Connexion
  Future<User> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      return response.user;
    } catch (e) {
      throw _handleException(e);
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _apiService.logout();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: ${e.toString()}');
    }
  }

  // Réinitialisation mot de passe (à implémenter côté API)
  Future<void> resetPassword(String email) async {
    throw Exception('Fonctionnalité non encore disponible');
  }

  // Obtenir les données utilisateur actuelles
  Future<User?> getCurrentUserData() async {
    try {
      return await _apiService.currentUser;
    } catch (e) {
      return null;
    }
  }

  // Mettre à jour les données utilisateur
  Future<void> updateUserData(User user) async {
    try {
      await _apiService.put('/users/${user.id}', body: user.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  // Obtenir les utilisateurs par type (pour directeur)
  Future<List<User>> getUsersByType(UserType userType) async {
    try {
      final response = await _apiService.get('/users?userType=${userType.name}');
      final apiResponse = _ApiResponse.fromJson(jsonDecode(response.body));

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> usersJson = apiResponse.data;
        return usersJson.map((userJson) => User.fromJson(userJson)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération: ${e.toString()}');
    }
  }

  // Désactiver un utilisateur (pour directeur)
  Future<void> deactivateUser(String userId) async {
    try {
      await _apiService.delete('/users/$userId');
    } catch (e) {
      throw Exception('Erreur lors de la désactivation: ${e.toString()}');
    }
  }

  // Vérifier si un email est déjà enregistré
  Future<bool> isEmailRegistered(String email) async {
    try {
      // Cette fonctionnalité pourrait être ajoutée à l'API
      return false;
    } catch (e) {
      return false;
    }
  }

  // Gestion des erreurs
  String _handleException(dynamic e) {
    final message = e.toString();

    if (message.contains('No internet connection')) {
      return 'Pas de connexion internet';
    } else if (message.contains('HTTP 400')) {
      return 'Requête invalide';
    } else if (message.contains('HTTP 401')) {
      return 'Session expirée, veuillez vous reconnecter';
    } else if (message.contains('HTTP 403')) {
      return 'Accès non autorisé';
    } else if (message.contains('HTTP 404')) {
      return 'Ressource non trouvée';
    } else if (message.contains('HTTP 500')) {
      return 'Erreur serveur, veuillez réessayer plus tard';
    } else if (message.contains('Email already exists')) {
      return 'Cette adresse email est déjà utilisée';
    } else if (message.contains('Invalid credentials')) {
      return 'Email ou mot de passe incorrect';
    } else if (message.contains('Password too short')) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    } else if (message.contains('Invalid email')) {
      return 'Adresse email invalide';
    } else if (message.contains('User not found')) {
      return 'Utilisateur non trouvé';
    } else if (message.contains('Session expired')) {
      return 'Session expirée, veuillez vous reconnecter';
    } else {
      return 'Erreur inattendue: $message';
    }
  }
}

// Classe pour gérer les réponses API
class _ApiResponse {
  final bool success;
  final dynamic data;
  final String message;

  _ApiResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory _ApiResponse.fromJson(Map<String, dynamic> json) {
    return _ApiResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? '',
    );
  }
}