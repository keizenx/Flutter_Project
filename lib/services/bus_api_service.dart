import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/bus_route.dart';
import '../config/api_config.dart';

class BusApiService {
  final String baseUrl = ApiConfig.baseUrl;
  final String apiVersion = ApiConfig.apiVersion;
  final String apiKey = ApiConfig.apiKey;

  Future<List<BusRoute>> fetchRoutes(
      String from, String to, DateTime date) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$apiVersion/search'),
        headers: {
          'Authorization': 'Token $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': ApiConfig.language,
        },
        body: json.encode({
          'origin_id': from,
          'destination_id': to,
          'date': date.toIso8601String().split('T')[0],
          'currency': ApiConfig.currency,
          'passengers': [
            {'id': 1, 'age': 30}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> trips = data['trips'] ?? [];

        return trips.map((trip) {
          return BusRoute(
            id: trip['id'],
            fromLocation: from,
            toLocation: to,
            departureTime: DateTime.parse(trip['departure']),
            arrivalTime: DateTime.parse(trip['arrival']),
            price: trip['is_promo']
                ? trip['price_promo_cents'] / 100.0
                : trip['price_cents'] / 100.0,
            availableSeats: 45, // Par défaut car non fourni par l'API
            busCompany: trip['carrier']['name'] ?? 'FlixBus',
            busType: 'Standard',
            amenities: ['WiFi', 'Prises électriques', 'Climatisation'],
            rating: 4.5,
          );
        }).toList();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load routes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching routes: $e');
      return _getSimulatedRoutes(from, to, date);
    }
  }

  int _calculateDuration(String departure, String arrival) {
    final departureTime = DateTime.parse(departure);
    final arrivalTime = DateTime.parse(arrival);
    return arrivalTime.difference(departureTime).inMinutes;
  }

  Future<List<String>> fetchPopularCities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$apiVersion/stops'),
        headers: {
          'Authorization': 'Token $apiKey',
          'Accept': 'application/json',
          'Accept-Language': ApiConfig.language,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> stops = data['stops'] ?? [];

        return stops
            .where((stop) => !stop['is_meta_gare'])
            .map<String>((stop) => stop['long_name_fr'] as String)
            .toList();
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      print('Error fetching cities: $e');
      return _getDefaultCities();
    }
  }

  List<String> _getDefaultCities() {
    return [
      'Abidjan',
      'Yamoussoukro',
      'Bouaké',
      'Korhogo',
      'San Pedro',
      'Daloa',
      'Man',
      'Gagnoa',
      'Abengourou',
      'Divo',
    ];
  }

  List<BusRoute> _getSimulatedRoutes(String from, String to, DateTime date) {
    final List<DateTime> departureTimes = [
      DateTime(date.year, date.month, date.day, 6, 0),
      DateTime(date.year, date.month, date.day, 8, 30),
      DateTime(date.year, date.month, date.day, 10, 0),
      DateTime(date.year, date.month, date.day, 13, 30),
      DateTime(date.year, date.month, date.day, 16, 0),
      DateTime(date.year, date.month, date.day, 18, 30),
    ];

    return departureTimes.map((departureTime) {
      final String id = 'BUS-${departureTime.hour}${departureTime.minute}';
      final double basePrice = 5000.0;
      final int randomSeats = 20 + (DateTime.now().millisecond % 30);
      final arrivalTime = departureTime.add(const Duration(hours: 2));

      return BusRoute(
        id: id,
        fromLocation: from,
        toLocation: to,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        price: basePrice + (departureTime.hour < 10 ? 1000 : 0),
        availableSeats: randomSeats,
        busCompany: 'UTB',
        busType: 'Standard',
        amenities: ['WiFi', 'Prises électriques', 'Climatisation'],
        rating: 4.2,
      );
    }).toList();
  }

  Future<Map<String, dynamic>> searchCities(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$apiVersion/stops?q=$query'),
        headers: {
          'Authorization': 'Token $apiKey',
          'Accept': 'application/json',
          'Accept-Language': ApiConfig.language,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search cities');
      }
    } catch (e) {
      print('Error searching cities: $e');
      return {'stops': []};
    }
  }
}
