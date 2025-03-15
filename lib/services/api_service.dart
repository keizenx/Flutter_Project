import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/bus_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/booking_service.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Cache pour les résultats de recherche
  final Map<String, List<BusRoute>> _routeCache = {};

  // Cache pour les détails des bus
  final Map<String, Map<String, dynamic>> _busDetailsCache = {};

  // Cache pour les disponibilités de sièges
  final Map<String, Map<String, bool>> _seatAvailabilityCache = {};

  // Durée de validité du cache (en minutes)
  final int _cacheDuration = 15;

  // Timestamps pour le cache
  final Map<String, DateTime> _cacheTimestamps = {};

  // Cache pour les données
  final Map<String, dynamic> _memoryCache = {};

  // URL de base de l'API (à remplacer par votre URL réelle)
  final String _baseUrl = 'https://api.busreservation.com/v1';

  // Méthode pour rechercher des itinéraires
  Future<List<BusRoute>> searchRoutes({
    required String from,
    required String to,
    required DateTime date,
    bool forceRefresh = false,
  }) async {
    // Clé de cache
    final cacheKey = '${from}_${to}_${date.year}-${date.month}-${date.day}';

    // Vérifier si les données sont en cache et toujours valides
    if (!forceRefresh &&
        _routeCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey]!;
      final now = DateTime.now();
      if (now.difference(cacheTime).inMinutes < _cacheDuration) {
        return _routeCache[cacheKey]!;
      }
    }

    try {
      // Dans un environnement réel, vous feriez un appel API comme celui-ci:
      // final apiKey = dotenv.env['BUS_API_KEY'];
      // final response = await http.get(
      //   Uri.parse('https://api.busservice.com/routes?from=$from&to=$to&date=${date.toIso8601String()}'),
      //   headers: {'Authorization': 'Bearer $apiKey'},
      // );

      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   final List<BusRoute> routes = (data['routes'] as List)
      //       .map((route) => BusRoute.fromJson(route))
      //       .toList();
      //
      //   // Mettre en cache les résultats
      //   _routeCache[cacheKey] = routes;
      //   _cacheTimestamps[cacheKey] = DateTime.now();
      //
      //   return routes;
      // } else {
      //   throw Exception('Failed to load routes');
      // }

      // Pour l'exemple, nous générons des données de test
      // Simuler un délai réseau minimal pour éviter les lags
      await Future.delayed(const Duration(milliseconds: 300));

      // Générer des données de test
      final routes = BusRoute.generateMockRoutes(
        from: from,
        to: to,
        date: date,
      );

      // Mettre en cache les résultats
      _routeCache[cacheKey] = routes;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return routes;
    } catch (e) {
      // En cas d'erreur, retourner les données en cache si disponibles
      if (_routeCache.containsKey(cacheKey)) {
        return _routeCache[cacheKey]!;
      }
      rethrow;
    }
  }

  // Méthode pour obtenir les détails d'un bus
  Future<Map<String, dynamic>> getBusDetails(String busId,
      {bool forceRefresh = false}) async {
    // Vérifier si les données sont en cache
    if (!forceRefresh && _busDetailsCache.containsKey(busId)) {
      return _busDetailsCache[busId]!;
    }

    try {
      // Simuler un appel API
      await Future.delayed(const Duration(milliseconds: 200));

      // Générer des données de test
      final details = {
        'id': busId,
        'licensePlate': 'AB-${busId.substring(3)}',
        'model': 'Mercedes-Benz Tourismo',
        'year': 2020 + (int.parse(busId.substring(3)) % 5),
        'totalSeats': 50,
        'features': [
          'WiFi',
          'Air Conditioning',
          'Power Outlets',
          'Toilet',
          'Entertainment System',
        ],
        'lastMaintenance':
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'driverName': 'John Doe',
        'driverRating': 4.8,
      };

      // Mettre en cache les résultats
      _busDetailsCache[busId] = details;

      return details;
    } catch (e) {
      rethrow;
    }
  }

  // Méthode pour obtenir la disponibilité des sièges
  Future<Map<int, bool>> getSeatAvailability(
      String busId, DateTime departureTime) async {
    final cacheKey =
        'seat_availability_${busId}_${departureTime.toIso8601String()}';

    // Vérifier si les données sont en cache mémoire
    if (_memoryCache.containsKey(cacheKey)) {
      final cachedData = _memoryCache[cacheKey];
      final timestamp = cachedData['timestamp'] as int;

      // Vérifier si le cache est encore valide (moins de 15 minutes)
      if (DateTime.now().millisecondsSinceEpoch - timestamp <
          _cacheDuration * 60 * 1000) {
        debugPrint('Utilisation du cache mémoire pour $cacheKey');

        final Map<String, dynamic> seatMap = cachedData['data'];
        // Convertir les clés string en int pour l'interface
        return seatMap
            .map((key, value) => MapEntry(int.parse(key), value as bool));
      }
    }

    // Vérifier si les données sont en cache persistant
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);

      if (cachedJson != null) {
        final cachedData = json.decode(cachedJson);
        final timestamp = cachedData['timestamp'] as int;

        // Vérifier si le cache est encore valide (moins de 15 minutes)
        if (DateTime.now().millisecondsSinceEpoch - timestamp <
            _cacheDuration * 60 * 1000) {
          debugPrint('Utilisation du cache persistant pour $cacheKey');

          // Mettre à jour le cache mémoire
          _memoryCache[cacheKey] = cachedData;

          final Map<String, dynamic> seatMap = cachedData['data'];
          // Convertir les clés string en int pour l'interface
          return seatMap
              .map((key, value) => MapEntry(int.parse(key), value as bool));
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la lecture du cache: $e');
    }

    // Si pas en cache ou cache expiré, faire un appel API
    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 800));

      // Dans un environnement réel, vous feriez un appel API comme celui-ci:
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/buses/$busId/seats?departure=${departureTime.toIso8601String()}'),
      //   headers: {'Authorization': 'Bearer $apiKey'},
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   // Traiter les données
      // } else {
      //   throw Exception('Failed to load seat availability');
      // }

      // Pour l'exemple, nous générons des données aléatoires mais cohérentes
      final Map<String, bool> availability = {};
      for (int i = 1; i <= 50; i++) {
        // Utiliser l'ID du bus et le numéro de siège pour générer une disponibilité cohérente
        availability[i.toString()] = !((busId.codeUnitAt(0) + i) % 7 == 0);
      }

      // Mettre en cache les résultats
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': availability,
      };

      // Mettre à jour le cache mémoire
      _memoryCache[cacheKey] = cacheData;

      // Mettre à jour le cache persistant
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, json.encode(cacheData));
      } catch (e) {
        debugPrint('Erreur lors de l\'écriture du cache: $e');
      }

      // Convertir les clés string en int pour l'interface
      return availability.map((key, value) => MapEntry(int.parse(key), value));
    } catch (e) {
      debugPrint('Erreur lors de l\'appel API: $e');
      throw Exception('Erreur lors du chargement des sièges disponibles: $e');
    }
  }

  // Méthode pour effectuer une réservation
  Future<Map<String, dynamic>> bookTicket({
    required String busId,
    required List<int> seats,
    required String passengerName,
    required String passengerEmail,
    required String passengerPhone,
    required DateTime departureTime,
    String? routeFrom,
    String? routeTo,
  }) async {
    try {
      // Importer le service de réservation
      final bookingService = BookingService();

      // Récupérer l'ID utilisateur (simulé pour l'exemple)
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ??
          '1'; // Utiliser l'ID par défaut si non connecté

      // Calculer l'heure d'arrivée (2 heures après le départ par défaut)
      final arrivalTime = departureTime.add(const Duration(hours: 2));

      // Déterminer le prix (simulé pour l'exemple)
      final double price = 5000.0; // Prix par défaut

      // Créer la réservation réelle
      final bookingResult = await bookingService.createBooking(
        userId: userId,
        busId: busId,
        routeFrom: routeFrom ??
            'Abidjan', // Utiliser la valeur fournie ou la valeur par défaut
        routeTo: routeTo ??
            'Yamoussoukro', // Utiliser la valeur fournie ou la valeur par défaut
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        seatNumber: seats.first, // Utiliser le premier siège sélectionné
        price: price,
        paymentMethod: 'orange_money', // Méthode de paiement par défaut
      );

      if (bookingResult['success']) {
        // Mettre à jour le cache des sièges disponibles
        final cacheKey =
            'seat_availability_${busId}_${departureTime.toIso8601String()}';

        if (_memoryCache.containsKey(cacheKey)) {
          final cachedData = _memoryCache[cacheKey];

          // Vérifier si les données sont au bon format
          if (cachedData != null && cachedData['data'] != null) {
            // Convertir en Map<String, bool> pour la mise à jour
            final Map<String, bool> seatAvailability =
                Map<String, bool>.from(cachedData['data']);

            // Marquer les sièges comme réservés
            for (final seat in seats) {
              seatAvailability[seat.toString()] = false;
            }

            // Mettre à jour le cache mémoire
            _memoryCache[cacheKey] = {
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'data': seatAvailability,
            };

            // Mettre à jour le cache persistant
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(
                  cacheKey, json.encode(_memoryCache[cacheKey]));
            } catch (e) {
              debugPrint('Erreur lors de l\'écriture du cache: $e');
            }
          }
        }

        return {
          'reference': bookingResult['booking_reference'],
          'status': 'confirmed',
          'seats': seats,
          'passengerName': passengerName,
          'departureTime': departureTime.toIso8601String(),
        };
      } else {
        throw Exception('Échec de la réservation: ${bookingResult['message']}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la réservation: $e');
      throw Exception('Erreur lors de la réservation du billet: $e');
    }
  }

  // Méthode pour annuler un billet
  Future<bool> cancelTicket(String bookingReference) async {
    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 800));

      // Dans un environnement réel, vous feriez un appel API comme celui-ci:
      // final response = await http.delete(
      //   Uri.parse('$_baseUrl/bookings/$bookingReference'),
      //   headers: {'Authorization': 'Bearer $apiKey'},
      // );
      //
      // return response.statusCode == 200;

      // Pour l'exemple, nous retournons toujours true
      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'annulation: $e');
      throw Exception('Erreur lors de l\'annulation du billet: $e');
    }
  }

  // Méthode pour obtenir les détails d'un billet
  Future<Map<String, dynamic>> getTicketDetails(String bookingReference) async {
    final cacheKey = 'ticket_details_$bookingReference';

    // Vérifier si les données sont en cache mémoire
    if (_memoryCache.containsKey(cacheKey)) {
      final cachedData = _memoryCache[cacheKey];
      final timestamp = cachedData['timestamp'] as int;

      // Vérifier si le cache est encore valide (moins de 15 minutes)
      if (DateTime.now().millisecondsSinceEpoch - timestamp <
          _cacheDuration * 60 * 1000) {
        debugPrint('Utilisation du cache mémoire pour $cacheKey');
        return Map<String, dynamic>.from(cachedData['data']);
      }
    }

    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 500));

      // Dans un environnement réel, vous feriez un appel API comme celui-ci:
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/bookings/$bookingReference'),
      //   headers: {'Authorization': 'Bearer $apiKey'},
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   // Mettre en cache les résultats
      //   _memoryCache[cacheKey] = {
      //     'timestamp': DateTime.now().millisecondsSinceEpoch,
      //     'data': data,
      //   };
      //   return data;
      // } else {
      //   throw Exception('Failed to load ticket details');
      // }

      // Pour l'exemple, nous générons des données fictives
      final ticketDetails = {
        'reference': bookingReference,
        'status': 'confirmed',
        'passengerName': 'John Doe',
        'route': 'Paris → Lyon',
        'departureTime':
            DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'arrivalTime': DateTime.now()
            .add(const Duration(days: 2, hours: 4))
            .toIso8601String(),
        'seatNumber': 12,
        'busCompany': 'FlixBus',
        'platform': 'A4',
      };

      // Mettre en cache les résultats
      _memoryCache[cacheKey] = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': ticketDetails,
      };

      return ticketDetails;
    } catch (e) {
      debugPrint('Erreur lors du chargement des détails du billet: $e');
      throw Exception('Erreur lors du chargement des détails du billet: $e');
    }
  }

  // Méthode pour vider le cache
  Future<void> clearCache() async {
    _routeCache.clear();
    _busDetailsCache.clear();
    _seatAvailabilityCache.clear();
    _cacheTimestamps.clear();
    _memoryCache.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) =>
          key.startsWith('seat_availability_') ||
          key.startsWith('ticket_details_'));

      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Erreur lors de la suppression du cache: $e');
    }
  }
}
