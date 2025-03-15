import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/database_service.dart';
import '../services/email_service.dart';

class BusTrackingService extends ChangeNotifier {
  static final BusTrackingService _instance = BusTrackingService._internal();
  final DatabaseService _databaseService = DatabaseService();
  final EmailService _emailService = EmailService();

  // Simuler les positions des bus
  final Map<String, BusLocation> _busLocations = {};
  final Map<String, Timer> _simulationTimers = {};

  // Abonnements aux mises à jour de bus
  final Map<String, List<Function(BusLocation)>> _busSubscriptions = {};

  factory BusTrackingService() => _instance;

  BusTrackingService._internal();

  // Obtenir la position actuelle d'un bus
  BusLocation? getBusLocation(String busId) {
    return _busLocations[busId];
  }

  // Obtenir toutes les positions des bus
  Map<String, BusLocation> getAllBusLocations() {
    return Map.unmodifiable(_busLocations);
  }

  // Initialiser le service avec les bus actifs
  Future<void> initialize() async {
    try {
      final sp = await _databaseService.prefs;
      final busesJson = sp.getString('buses') ?? '[]';
      final busesList = jsonDecode(busesJson) as List;

      final buses =
          busesList.where((bus) => bus['status'] == 'active').toList();

      for (final bus in buses) {
        final busId = bus['id'] as String;

        // Simuler une position initiale pour chaque bus
        // Abidjan: 5.3364, -4.0267
        // Yamoussoukro: 6.8276, -5.2893
        // Bouaké: 7.6881, -5.0377
        // San Pedro: 4.7485, -6.6363

        // Choisir une position aléatoire en Côte d'Ivoire
        final random = Random();
        final lat = 5.0 + random.nextDouble() * 3.0; // Entre 5.0 et 8.0
        final lng = -6.5 + random.nextDouble() * 2.5; // Entre -6.5 et -4.0

        final initialLocation = BusLocation(
          busId: busId,
          busName: bus['name'] as String,
          position: LatLng(lat, lng),
          heading: random.nextDouble() * 360, // Direction aléatoire
          speed: 40 + random.nextDouble() * 20, // Vitesse entre 40 et 60 km/h
          lastUpdated: DateTime.now(),
          status: 'En route',
          delay: 0,
        );

        _busLocations[busId] = initialLocation;

        // Démarrer la simulation pour ce bus
        _startBusSimulation(busId);
      }

      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'initialisation du service de suivi: $e');
    }
  }

  // S'abonner aux mises à jour d'un bus spécifique
  void subscribeToBus(String busId, Function(BusLocation) callback) {
    if (!_busSubscriptions.containsKey(busId)) {
      _busSubscriptions[busId] = [];
    }

    _busSubscriptions[busId]!.add(callback);
  }

  // Se désabonner des mises à jour d'un bus
  void unsubscribeFromBus(String busId, Function(BusLocation) callback) {
    if (_busSubscriptions.containsKey(busId)) {
      _busSubscriptions[busId]!.remove(callback);

      if (_busSubscriptions[busId]!.isEmpty) {
        _busSubscriptions.remove(busId);
      }
    }
  }

  // Démarrer la simulation pour un bus
  void _startBusSimulation(String busId) {
    // Arrêter toute simulation existante pour ce bus
    _stopBusSimulation(busId);

    // Créer un timer pour mettre à jour la position du bus toutes les 5 secondes
    _simulationTimers[busId] =
        Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateBusLocation(busId);
    });
  }

  // Arrêter la simulation pour un bus
  void _stopBusSimulation(String busId) {
    if (_simulationTimers.containsKey(busId)) {
      _simulationTimers[busId]!.cancel();
      _simulationTimers.remove(busId);
    }
  }

  // Mettre à jour la position simulée d'un bus
  void _updateBusLocation(String busId) {
    if (!_busLocations.containsKey(busId)) return;

    final currentLocation = _busLocations[busId]!;
    final random = Random();

    // Simuler un mouvement dans la direction actuelle
    final distance = currentLocation.speed *
        5 /
        3600; // Distance en km parcourue en 5 secondes
    final distanceDegrees = distance /
        111.32; // Conversion approximative en degrés (1 degré ≈ 111.32 km)

    // Calculer la nouvelle position
    final headingRadians = currentLocation.heading * pi / 180;
    final newLat = currentLocation.position.latitude +
        distanceDegrees * cos(headingRadians);
    final newLng = currentLocation.position.longitude +
        distanceDegrees * sin(headingRadians);

    // Simuler de légères variations de direction et de vitesse
    final newHeading =
        (currentLocation.heading + (random.nextDouble() * 20 - 10)) % 360;
    final newSpeed = max(30.0,
        min(80.0, currentLocation.speed + (random.nextDouble() * 10 - 5)));

    // Simuler occasionnellement un retard
    int delay = currentLocation.delay;
    if (random.nextDouble() < 0.05) {
      // 5% de chance de changer le retard
      delay = max(
          0,
          delay +
              (random.nextInt(5) -
                  2)); // Ajouter ou soustraire jusqu'à 2 minutes
    }

    // Simuler occasionnellement un changement de statut
    String status = currentLocation.status;
    if (random.nextDouble() < 0.02) {
      // 2% de chance de changer le statut
      final statuses = ['En route', 'Arrêt', 'Embarquement', 'Débarquement'];
      status = statuses[random.nextInt(statuses.length)];
    }

    // Créer la nouvelle position
    final newLocation = BusLocation(
      busId: busId,
      busName: currentLocation.busName,
      position: LatLng(newLat, newLng),
      heading: newHeading,
      speed: newSpeed,
      lastUpdated: DateTime.now(),
      status: status,
      delay: delay,
    );

    // Mettre à jour la position
    _busLocations[busId] = newLocation;

    // Notifier les abonnés
    if (_busSubscriptions.containsKey(busId)) {
      for (final callback in _busSubscriptions[busId]!) {
        callback(newLocation);
      }
    }

    notifyListeners();

    // Si le retard a changé, envoyer une notification aux utilisateurs concernés
    if (delay != currentLocation.delay) {
      _notifyUsersOfDelay(busId, delay);
    }
  }

  // Notifier les utilisateurs d'un retard
  Future<void> _notifyUsersOfDelay(String busId, int delayMinutes) async {
    try {
      final sp = await _databaseService.prefs;

      // Récupérer les réservations actives pour ce bus
      final bookingsJson = sp.getString('bookings') ?? '[]';
      final bookingsList = jsonDecode(bookingsJson) as List;
      final bookings = bookingsList
          .where((booking) =>
              booking['bus_id'] == busId && booking['status'] == 'confirmed')
          .toList();

      for (final booking in bookings) {
        // Convertir l'ID utilisateur en int si c'est une chaîne
        final userId = booking['user_id'] is String
            ? int.parse(booking['user_id'] as String)
            : booking['user_id'] as int;

        final usersJson = sp.getString('users') ?? '[]';
        final usersList = jsonDecode(usersJson) as List;
        final userResults =
            usersList.where((user) => user['id'] == userId).toList();

        if (userResults.isNotEmpty) {
          final user = userResults.first;
          final userName = user['name'] as String;
          final userEmail = user['email'] as String;

          // Envoyer un email de notification de retard
          if (delayMinutes > 0) {
            await _emailService.sendBusStatusUpdate(
              to: userEmail,
              name: userName,
              bookingReference: booking['booking_reference'] as String,
              routeFrom: booking['route_from'] as String,
              routeTo: booking['route_to'] as String,
              departureTime: booking['departure_time'] as String,
              status: 'Retardé',
              message:
                  'Votre bus est actuellement en retard de $delayMinutes minutes. Nous nous excusons pour ce désagrément.',
            );
          } else {
            await _emailService.sendBusStatusUpdate(
              to: userEmail,
              name: userName,
              bookingReference: booking['booking_reference'] as String,
              routeFrom: booking['route_from'] as String,
              routeTo: booking['route_to'] as String,
              departureTime: booking['departure_time'] as String,
              status: 'À l\'heure',
              message:
                  'Votre bus est maintenant à l\'heure. Merci de votre patience.',
            );
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la notification des utilisateurs: $e');
    }
  }

  // Obtenir les détails d'un bus
  Future<Map<String, dynamic>?> getBusDetails(String busId) async {
    try {
      final sp = await _databaseService.prefs;
      final busesJson = sp.getString('buses') ?? '[]';
      final busesList = jsonDecode(busesJson) as List;

      final results = busesList.where((bus) => bus['id'] == busId).toList();

      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération des détails du bus: $e');
      return null;
    }
  }

  // Obtenir les arrêts prévus pour un bus
  Future<List<Map<String, dynamic>>> getBusStops(String busId) async {
    // Simuler des arrêts pour le bus
    final random = Random();
    final stops = <Map<String, dynamic>>[];

    // Principales villes de Côte d'Ivoire
    final cities = [
      {'name': 'Abidjan', 'lat': 5.3364, 'lng': -4.0267},
      {'name': 'Yamoussoukro', 'lat': 6.8276, 'lng': -5.2893},
      {'name': 'Bouaké', 'lat': 7.6881, 'lng': -5.0377},
      {'name': 'San Pedro', 'lat': 4.7485, 'lng': -6.6363},
      {'name': 'Korhogo', 'lat': 9.4578, 'lng': -5.6294},
      {'name': 'Man', 'lat': 7.4121, 'lng': -7.5469},
      {'name': 'Daloa', 'lat': 6.8772, 'lng': -6.4444},
      {'name': 'Gagnoa', 'lat': 6.1333, 'lng': -5.9500},
    ];

    // Sélectionner 3 à 5 villes aléatoires pour les arrêts
    final selectedCities = List.from(cities)..shuffle(random);
    final stopCount = 3 + random.nextInt(3); // Entre 3 et 5 arrêts

    final now = DateTime.now();
    var currentTime = now;

    for (var i = 0; i < min(stopCount, selectedCities.length); i++) {
      final city = selectedCities[i];

      // Ajouter un temps entre les arrêts (entre 30 minutes et 2 heures)
      if (i > 0) {
        currentTime =
            currentTime.add(Duration(minutes: 30 + random.nextInt(90)));
      }

      stops.add({
        'city': city['name'],
        'position': LatLng(city['lat'] as double, city['lng'] as double),
        'arrival_time': currentTime,
        'departure_time':
            currentTime.add(Duration(minutes: 10 + random.nextInt(10))),
        'status':
            i == 0 ? 'Départ' : (i == stopCount - 1 ? 'Arrivée' : 'Arrêt'),
      });
    }

    return stops;
  }

  // Nettoyer les ressources lors de la fermeture de l'application
  void dispose() {
    // Arrêter toutes les simulations
    for (final timer in _simulationTimers.values) {
      timer.cancel();
    }
    _simulationTimers.clear();
    super.dispose();
  }
}

class BusLocation {
  final String busId;
  final String busName;
  final LatLng position;
  final double heading; // En degrés (0-360)
  final double speed; // En km/h
  final DateTime lastUpdated;
  final String status; // 'En route', 'Arrêt', 'Embarquement', 'Débarquement'
  final int delay; // Retard en minutes

  BusLocation({
    required this.busId,
    required this.busName,
    required this.position,
    required this.heading,
    required this.speed,
    required this.lastUpdated,
    required this.status,
    required this.delay,
  });
}
