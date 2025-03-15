import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../services/email_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  final DatabaseService _databaseService = DatabaseService();
  final EmailService _emailService = EmailService();

  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;

  factory AuthService() => _instance;

  AuthService._internal();

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser;

  // Initialiser l'état d'authentification au démarrage de l'application
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null) {
      final sp = await _databaseService.prefs;
      final users = jsonDecode(sp.getString('users') ?? '[]') as List;

      final userList =
          users.where((user) => user['id'].toString() == userId).toList();

      if (userList.isNotEmpty) {
        _currentUser = Map<String, dynamic>.from(userList.first);
        _isAuthenticated = true;
        notifyListeners();
      }
    }
  }

  // Hacher un mot de passe
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Générer un jeton de réinitialisation de mot de passe
  String _generateResetToken() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  // Inscription d'un nouvel utilisateur
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Vérifier si l'email existe déjà
      final existingUser = await _databaseService.getUserByEmail(email);

      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Cet email est déjà utilisé',
        };
      }

      // Hacher le mot de passe
      final hashedPassword = _hashPassword(password);

      // Créer l'utilisateur
      final userData = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': hashedPassword,
      };

      final userId = await _databaseService.insertUser(userData);

      if (userId.isNotEmpty) {
        // Récupérer l'utilisateur créé
        final sp = await _databaseService.prefs;
        final users = jsonDecode(sp.getString('users') ?? '[]') as List;

        final userList =
            users.where((user) => user['id'].toString() == userId).toList();

        if (userList.isNotEmpty) {
          _currentUser = Map<String, dynamic>.from(userList.first);
          _isAuthenticated = true;

          // Sauvegarder l'ID de l'utilisateur dans les préférences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userId);

          notifyListeners();

          return {
            'success': true,
            'message': 'Inscription réussie',
            'user': _currentUser,
          };
        }
      }

      return {
        'success': false,
        'message': 'Erreur lors de l\'inscription',
      };
    } catch (e) {
      print('Erreur d\'inscription détaillée: $e');
      // Capturer la trace de la pile pour le débogage
      print(StackTrace.current);
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Connexion d'un utilisateur
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _databaseService.getUserByEmail(email);

      if (user == null) {
        return {
          'success': false,
          'message': 'Email ou mot de passe incorrect',
        };
      }

      final hashedPassword = _hashPassword(password);

      if (user['password'] != hashedPassword) {
        return {
          'success': false,
          'message': 'Email ou mot de passe incorrect',
        };
      }

      _currentUser = user;
      _isAuthenticated = true;

      // Sauvegarder l'ID de l'utilisateur dans les préférences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user['id'] as String);

      notifyListeners();

      return {
        'success': true,
        'message': 'Connexion réussie',
        'user': _currentUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;

    // Supprimer l'ID de l'utilisateur des préférences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');

    notifyListeners();
  }

  // Mettre à jour le profil de l'utilisateur
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final result = await _databaseService.updateUser(userId, userData);

      if (result > 0) {
        // Mettre à jour l'utilisateur courant
        if (_currentUser != null && _currentUser!['id'] == userId) {
          final sp = await _databaseService.prefs;
          final users = jsonDecode(sp.getString('users') ?? '[]') as List;

          final userList =
              users.where((user) => user['id'].toString() == userId).toList();

          if (userList.isNotEmpty) {
            _currentUser = Map<String, dynamic>.from(userList.first);
            notifyListeners();
          }
        }

        return {
          'success': true,
          'message': 'Profil mis à jour avec succès',
          'user': _currentUser,
        };
      }

      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour du profil',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Mettre à jour le mot de passe
  Future<Map<String, dynamic>> updatePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final sp = await _databaseService.prefs;
      final users = jsonDecode(sp.getString('users') ?? '[]') as List;

      final userList =
          users.where((user) => user['id'].toString() == userId).toList();

      if (userList.isEmpty) {
        return {
          'success': false,
          'message': 'Utilisateur non trouvé',
        };
      }

      final user = userList.first;
      final hashedCurrentPassword = _hashPassword(currentPassword);

      if (user['password'] != hashedCurrentPassword) {
        return {
          'success': false,
          'message': 'Mot de passe actuel incorrect',
        };
      }

      final hashedNewPassword = _hashPassword(newPassword);

      final result = await _databaseService.updateUser(userId, {
        'password': hashedNewPassword,
      });

      if (result > 0) {
        return {
          'success': true,
          'message': 'Mot de passe mis à jour avec succès',
        };
      }

      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour du mot de passe',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Demander une réinitialisation de mot de passe
  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final user = await _databaseService.getUserByEmail(email);

      if (user == null) {
        // Pour des raisons de sécurité, ne pas indiquer que l'email n'existe pas
        return {
          'success': true,
          'message':
              'Si cet email existe, un lien de réinitialisation a été envoyé',
        };
      }

      final resetToken = _generateResetToken();
      final expiryTime = DateTime.now().add(const Duration(hours: 24));

      // Mettre à jour l'utilisateur avec le jeton de réinitialisation
      await _databaseService.updateUser(user['id'] as String, {
        'reset_token': resetToken,
        'reset_token_expiry': expiryTime.toIso8601String(),
      });

      // Construire le lien de réinitialisation
      final resetLink = 'https://ivoirebus.ci/reset-password?token=$resetToken';

      // Envoyer l'email de réinitialisation
      await _emailService.sendPasswordReset(
        to: email,
        name: user['name'] as String,
        resetLink: resetLink,
      );

      return {
        'success': true,
        'message':
            'Si cet email existe, un lien de réinitialisation a été envoyé',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Réinitialiser le mot de passe avec un jeton
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final sp = await _databaseService.prefs;
      final users = jsonDecode(sp.getString('users') ?? '[]') as List;
      final now = DateTime.now().toIso8601String();

      final validUsers = users
          .where((user) =>
              user['reset_token'] == token &&
              user['reset_token_expiry'] != null &&
              user['reset_token_expiry'].compareTo(now) > 0)
          .toList();

      if (validUsers.isEmpty) {
        return {
          'success': false,
          'message': 'Jeton de réinitialisation invalide ou expiré',
        };
      }

      final user = validUsers.first;
      final hashedNewPassword = _hashPassword(newPassword);

      final result = await _databaseService.updateUser(user['id'] as String, {
        'password': hashedNewPassword,
        'reset_token': null,
        'reset_token_expiry': null,
      });

      if (result > 0) {
        return {
          'success': true,
          'message': 'Mot de passe réinitialisé avec succès',
        };
      }

      return {
        'success': false,
        'message': 'Erreur lors de la réinitialisation du mot de passe',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }
}
