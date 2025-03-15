class BusRoute {
  final String id;
  final String fromLocation;
  final String toLocation;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final String busCompany;
  final String busType;
  final int availableSeats;
  final List<String> amenities;
  final double rating;

  BusRoute({
    required this.id,
    required this.fromLocation,
    required this.toLocation,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.busCompany,
    required this.busType,
    required this.availableSeats,
    required this.amenities,
    required this.rating,
  });

  // Durée du trajet en minutes
  int get durationMinutes => arrivalTime.difference(departureTime).inMinutes;

  // Durée formatée (ex: "2h 30m")
  String get duration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return hours > 0
        ? '$hours h ${minutes > 0 ? '$minutes m' : ''}'
        : '$minutes m';
  }

  // Méthode pour calculer la durée du trajet en minutes
  int getDurationInMinutes() {
    return arrivalTime.difference(departureTime).inMinutes;
  }

  // Conversion depuis JSON
  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      id: json['id'],
      fromLocation: json['fromLocation'],
      toLocation: json['toLocation'],
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      price: json['price'].toDouble(),
      busCompany: json['busCompany'],
      busType: json['busType'],
      availableSeats: json['availableSeats'],
      amenities: List<String>.from(json['amenities']),
      rating: json['rating'].toDouble(),
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'price': price,
      'busCompany': busCompany,
      'busType': busType,
      'availableSeats': availableSeats,
      'amenities': amenities,
      'rating': rating,
    };
  }

  // Méthode pour créer une copie modifiée
  BusRoute copyWith({
    String? id,
    String? fromLocation,
    String? toLocation,
    DateTime? departureTime,
    DateTime? arrivalTime,
    double? price,
    String? busCompany,
    String? busType,
    int? availableSeats,
    List<String>? amenities,
    double? rating,
  }) {
    return BusRoute(
      id: id ?? this.id,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      price: price ?? this.price,
      busCompany: busCompany ?? this.busCompany,
      busType: busType ?? this.busType,
      availableSeats: availableSeats ?? this.availableSeats,
      amenities: amenities ?? this.amenities,
      rating: rating ?? this.rating,
    );
  }

  // Méthode pour générer des données de test
  static List<BusRoute> generateMockRoutes({
    required String from,
    required String to,
    required DateTime date,
  }) {
    final List<BusRoute> routes = [];
    final List<String> busCompanies = [
      'FlixBus',
      'BlaBlaBus',
      'Eurolines',
      'Ouibus',
      'Alsa'
    ];
    final List<String> busTypes = ['Standard', 'Express', 'Luxury', 'Sleeper'];

    // Générer 15 itinéraires pour la journée
    for (int i = 0; i < 15; i++) {
      final departureTime = DateTime(
        date.year,
        date.month,
        date.day,
        6 + (i % 18), // Entre 6h et 23h
        (i * 7) % 60, // Minutes variées
      );

      final durationMinutes = 120 + (i * 30) % 240; // Entre 2h et 6h
      final arrivalTime = departureTime.add(Duration(minutes: durationMinutes));

      final price = 20.0 + (i * 5.5) % 180; // Entre 20€ et 200€
      final availableSeats = 5 + (i * 3) % 46; // Entre 5 et 50 sièges

      final busType = busTypes[i % busTypes.length];
      final busCompany = busCompanies[i % busCompanies.length];

      final List<String> amenities = [];
      final allAmenities = [
        'WiFi',
        'Power Outlets',
        'Toilet',
        'Air Conditioning',
        'Snacks',
        'Entertainment',
        'Reclining Seats',
        'Extra Legroom',
        'USB Ports',
        'Reading Lights',
        'Luggage Space',
        'Wheelchair Access'
      ];

      // Ajouter aléatoirement des équipements
      for (int j = 0; j < allAmenities.length; j++) {
        if ((i + j) % 3 == 0) {
          amenities.add(allAmenities[j]);
        }
      }

      routes.add(BusRoute(
        id: 'ROUTE${i.toString().padLeft(3, '0')}',
        fromLocation: from,
        toLocation: to,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        price: price,
        busCompany: busCompany,
        busType: busType,
        availableSeats: availableSeats,
        amenities: amenities,
        rating: 3.5 + (i % 3) * 0.5, // Entre 3.5 et 5.0
      ));
    }

    // Trier par heure de départ
    routes.sort((a, b) => a.departureTime.compareTo(b.departureTime));

    return routes;
  }
}
