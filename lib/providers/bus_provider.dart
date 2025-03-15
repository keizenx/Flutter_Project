import 'package:flutter/foundation.dart';
import '../models/bus_route.dart';
import '../services/bus_api_service.dart';

class BusProvider with ChangeNotifier {
  final BusApiService _apiService = BusApiService();
  List<BusRoute> _routes = [];
  final Map<String, List<BusRoute>> _routesCache = {};

  final List<String> _popularCities = [
    'Paris',
    'Lyon',
    'Marseille',
    'Toulouse',
    'Nice',
    'Nantes',
    'Strasbourg',
    'Montpellier',
    'Bordeaux',
    'Lille',
    'Rennes',
    'Reims',
    'Saint-Étienne',
    'Toulon',
    'Le Havre',
    'Grenoble',
  ];
  bool _isLoading = false;
  String? _error;

  List<BusRoute> get routes => _routes;
  List<String> get popularCities => _popularCities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Méthode optimisée pour filtrer les villes
  List<String> getSuggestions(String query) {
    if (query.isEmpty) {
      return _popularCities.take(5).toList();
    }

    query = query.toLowerCase();
    return _popularCities
        .where((city) => city.toLowerCase().contains(query))
        .take(5)
        .toList();
  }

  Future<void> searchRoutes(String from, String to, DateTime date) async {
    final String cacheKey =
        '${from}_${to}_${date.toIso8601String().split('T')[0]}';

    if (_routesCache.containsKey(cacheKey)) {
      _routes = _routesCache[cacheKey]!;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _routes = await _apiService.fetchRoutes(from, to, date);
      _routesCache[cacheKey] = _routes;
    } catch (e) {
      _error = 'Failed to load routes: $e';
      _routes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearRoutes() {
    _routes = [];
    notifyListeners();
  }

  void clearCache() {
    _routesCache.clear();
  }

  List<String> get locations {
    Set<String> locations = {};
    for (var route in _routes) {
      locations.add(route.fromLocation);
      locations.add(route.toLocation);
    }
    return locations.toList();
  }
}
