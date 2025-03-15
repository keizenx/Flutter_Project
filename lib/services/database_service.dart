import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static SharedPreferences? _prefs;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();

    // Initialiser les données de test si c'est la première fois
    if (!_prefs!.containsKey('initialized')) {
      await _initializeTestData();
      await _prefs!.setBool('initialized', true);
    }

    return _prefs!;
  }

  Future<void> _initializeTestData() async {
    // Utilisateurs de test
    final users = [
      {
        'id': '1',
        'name': 'Kouassi Georges',
        'email': 'kouassi.georges@example.com',
        'phone': '+225 0701234567',
        'password':
            'password123', // Dans une vraie application, ce serait hashé
        'profile_image': null,
        'created_at': DateTime.now().toIso8601String(),
      }
    ];
    await _prefs!.setString('users', jsonEncode(users));

    // Bus de test
    final buses = [
      {
        'id': 'BUS001',
        'name': 'Abidjan Express',
        'capacity': 45,
        'type': 'VIP',
        'features': 'WiFi, Climatisation, Prises électriques, Toilettes',
        'status': 'active',
      },
      {
        'id': 'BUS002',
        'name': 'Yamoussoukro Star',
        'capacity': 50,
        'type': 'Standard',
        'features': 'Climatisation, Toilettes',
        'status': 'active',
      },
      {
        'id': 'BUS003',
        'name': 'Côte d\'Ivoire Deluxe',
        'capacity': 35,
        'type': 'Premium',
        'features':
            'WiFi, Climatisation, Prises électriques, Toilettes, Sièges inclinables, Écrans individuels',
        'status': 'active',
      }
    ];
    await _prefs!.setString('buses', jsonEncode(buses));

    // Promotions de test
    final promotions = [
      {
        'id': '1',
        'title': 'Spécial Weekend',
        'description':
            'Profitez de 15% de réduction sur tous les trajets le weekend',
        'discount_percentage': 15.0,
        'discount_amount': null,
        'code': 'WEEKEND15',
        'start_date': DateTime.now().toIso8601String(),
        'end_date':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'is_active': 1,
      },
      {
        'id': '2',
        'title': 'Réduction Étudiant',
        'description':
            'Les étudiants bénéficient de 20% de réduction sur présentation de leur carte',
        'discount_percentage': 20.0,
        'discount_amount': null,
        'code': 'ETUDIANT20',
        'start_date': DateTime.now().toIso8601String(),
        'end_date':
            DateTime.now().add(const Duration(days: 90)).toIso8601String(),
        'is_active': 1,
      }
    ];
    await _prefs!.setString('promotions', jsonEncode(promotions));

    // Réservations, itinéraires favoris et méthodes de paiement vides
    await _prefs!.setString('bookings', jsonEncode([]));
    await _prefs!.setString('favorite_routes', jsonEncode([]));
    await _prefs!.setString('payment_methods', jsonEncode([]));
  }

  // Méthodes pour les utilisateurs
  Future<String> insertUser(Map<String, dynamic> user) async {
    final sp = await prefs;
    final users = jsonDecode(sp.getString('users') ?? '[]') as List;

    // Générer un nouvel ID
    final newId = users.isEmpty
        ? '1'
        : (int.parse(users.last['id'] as String) + 1).toString();

    // S'assurer que l'ID est une chaîne
    user['id'] = newId;
    user['created_at'] = DateTime.now().toIso8601String();

    // Convertir tous les champs numériques en chaînes si nécessaire
    if (user['phone'] is int) {
      user['phone'] = user['phone'].toString();
    }

    users.add(user);
    await sp.setString('users', jsonEncode(users));

    return newId;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final sp = await prefs;
    final users = jsonDecode(sp.getString('users') ?? '[]') as List;

    final matchingUsers =
        users.where((user) => user['email'] == email).toList();

    if (matchingUsers.isNotEmpty) {
      return Map<String, dynamic>.from(matchingUsers.first);
    }

    return null;
  }

  Future<int> updateUser(String id, Map<String, dynamic> userData) async {
    final sp = await prefs;
    final users = jsonDecode(sp.getString('users') ?? '[]') as List;

    final index = users.indexWhere((user) => user['id'] == id);

    if (index != -1) {
      // Mettre à jour les champs spécifiés
      userData.forEach((key, value) {
        users[index][key] = value;
      });

      await sp.setString('users', jsonEncode(users));
      return 1; // Succès
    }

    return 0; // Échec
  }

  // Méthodes pour les réservations
  Future<String> insertBooking(Map<String, dynamic> booking) async {
    final sp = await prefs;
    final bookings = jsonDecode(sp.getString('bookings') ?? '[]') as List;

    // Générer un nouvel ID
    final newId = bookings.isEmpty
        ? '1'
        : (int.parse(bookings.last['id'].toString()) + 1).toString();

    // S'assurer que l'ID est une chaîne
    booking['id'] = newId;
    booking['created_at'] = DateTime.now().toIso8601String();

    bookings.add(booking);
    await sp.setString('bookings', jsonEncode(bookings));

    return newId;
  }

  Future<List<Map<String, dynamic>>> getBookingsByUserId(String userId) async {
    final sp = await prefs;
    final bookings = jsonDecode(sp.getString('bookings') ?? '[]') as List;

    final userBookings = bookings
        .where((booking) => booking['user_id'].toString() == userId.toString())
        .map((booking) => Map<String, dynamic>.from(booking))
        .toList();

    // Trier par date de création (du plus récent au plus ancien)
    userBookings.sort((a, b) => DateTime.parse(b['created_at'])
        .compareTo(DateTime.parse(a['created_at'])));

    return userBookings;
  }

  Future<Map<String, dynamic>?> getBookingByReference(String reference) async {
    final sp = await prefs;
    final bookings = jsonDecode(sp.getString('bookings') ?? '[]') as List;

    final matchingBookings = bookings
        .where((booking) => booking['booking_reference'] == reference)
        .toList();

    if (matchingBookings.isNotEmpty) {
      return Map<String, dynamic>.from(matchingBookings.first);
    }

    return null;
  }

  Future<int> updateBookingStatus(String reference, String status) async {
    final sp = await prefs;
    final bookings = jsonDecode(sp.getString('bookings') ?? '[]') as List;

    final index = bookings
        .indexWhere((booking) => booking['booking_reference'] == reference);

    if (index != -1) {
      bookings[index]['status'] = status;
      await sp.setString('bookings', jsonEncode(bookings));
      return 1; // Succès
    }

    return 0; // Échec
  }

  // Méthodes pour les itinéraires favoris
  Future<String> insertFavoriteRoute(Map<String, dynamic> route) async {
    final sp = await prefs;
    final routes = jsonDecode(sp.getString('favorite_routes') ?? '[]') as List;

    // Générer un nouvel ID
    final newId = routes.isEmpty
        ? '1'
        : (int.parse(routes.last['id'].toString()) + 1).toString();

    route['id'] = newId;
    route['created_at'] = DateTime.now().toIso8601String();

    routes.add(route);
    await sp.setString('favorite_routes', jsonEncode(routes));

    return newId;
  }

  Future<List<Map<String, dynamic>>> getFavoriteRoutesByUserId(
      String userId) async {
    final sp = await prefs;
    final routes = jsonDecode(sp.getString('favorite_routes') ?? '[]') as List;

    return routes
        .where((route) => route['user_id'] == userId)
        .map((route) => Map<String, dynamic>.from(route))
        .toList();
  }

  Future<int> deleteFavoriteRoute(String id) async {
    final sp = await prefs;
    final routes = jsonDecode(sp.getString('favorite_routes') ?? '[]') as List;

    final initialLength = routes.length;
    final filteredRoutes = routes.where((route) => route['id'] != id).toList();

    await sp.setString('favorite_routes', jsonEncode(filteredRoutes));

    return initialLength - filteredRoutes.length; // Nombre d'éléments supprimés
  }

  // Méthodes pour les méthodes de paiement
  Future<String> insertPaymentMethod(Map<String, dynamic> method) async {
    final sp = await prefs;
    final methods = jsonDecode(sp.getString('payment_methods') ?? '[]') as List;

    // Si cette méthode est définie comme par défaut, réinitialiser les autres
    if (method['is_default'] == 1) {
      for (var i = 0; i < methods.length; i++) {
        if (methods[i]['user_id'] == method['user_id']) {
          methods[i]['is_default'] = 0;
        }
      }
    }

    // Générer un nouvel ID
    final newId = methods.isEmpty
        ? '1'
        : (int.parse(methods.last['id'].toString()) + 1).toString();

    method['id'] = newId;
    method['created_at'] = DateTime.now().toIso8601String();

    methods.add(method);
    await sp.setString('payment_methods', jsonEncode(methods));

    return newId;
  }

  Future<List<Map<String, dynamic>>> getPaymentMethodsByUserId(
      String userId) async {
    final sp = await prefs;
    final methods = jsonDecode(sp.getString('payment_methods') ?? '[]') as List;

    final userMethods = methods
        .where((method) => method['user_id'] == userId)
        .map((method) => Map<String, dynamic>.from(method))
        .toList();

    // Trier par défaut (les méthodes par défaut en premier)
    userMethods.sort(
        (a, b) => (b['is_default'] as int).compareTo(a['is_default'] as int));

    return userMethods;
  }

  Future<int> deletePaymentMethod(String id) async {
    final sp = await prefs;
    final methods = jsonDecode(sp.getString('payment_methods') ?? '[]') as List;

    final initialLength = methods.length;
    final filteredMethods =
        methods.where((method) => method['id'] != id).toList();

    await sp.setString('payment_methods', jsonEncode(filteredMethods));

    return initialLength -
        filteredMethods.length; // Nombre d'éléments supprimés
  }

  // Méthodes pour les promotions
  Future<List<Map<String, dynamic>>> getActivePromotions() async {
    final sp = await prefs;
    final promotions = jsonDecode(sp.getString('promotions') ?? '[]') as List;
    final now = DateTime.now().toIso8601String();

    return promotions
        .where((promo) =>
            promo['is_active'] == 1 &&
            promo['start_date'].compareTo(now) <= 0 &&
            promo['end_date'].compareTo(now) >= 0)
        .map((promo) => Map<String, dynamic>.from(promo))
        .toList();
  }

  Future<Map<String, dynamic>?> getPromotionByCode(String code) async {
    final sp = await prefs;
    final promotions = jsonDecode(sp.getString('promotions') ?? '[]') as List;
    final now = DateTime.now().toIso8601String();

    final matchingPromos = promotions
        .where((promo) =>
            promo['code'] == code &&
            promo['is_active'] == 1 &&
            promo['start_date'].compareTo(now) <= 0 &&
            promo['end_date'].compareTo(now) >= 0)
        .toList();

    if (matchingPromos.isNotEmpty) {
      return Map<String, dynamic>.from(matchingPromos.first);
    }

    return null;
  }
}
