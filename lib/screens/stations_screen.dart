import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  final List<BusStation> _stations = [
    BusStation(
      id: '1',
      name: 'Gare d\'Adjamé',
      address: 'Adjamé, Abidjan',
      city: 'Abidjan',
      facilities: ['Parking', 'Toilettes', 'Café', 'Wifi'],
      coordinates: const LatLng(5.3667, -4.0167),
      imageUrl: 'assets/images/bus_background.jpg',
    ),
    BusStation(
      id: '2',
      name: 'Gare de Yopougon',
      address: 'Yopougon, Abidjan',
      city: 'Abidjan',
      facilities: ['Parking', 'Toilettes', 'Boutique'],
      coordinates: const LatLng(5.3333, -4.0667),
      imageUrl: 'assets/images/bus_background.jpg',
    ),
    BusStation(
      id: '3',
      name: 'Gare de Yamoussoukro',
      address: 'Centre-ville, Yamoussoukro',
      city: 'Yamoussoukro',
      facilities: ['Parking', 'Toilettes', 'Café', 'Wifi', 'Consigne'],
      coordinates: const LatLng(6.8276, -5.2893),
      imageUrl: 'assets/images/bus_background.jpg',
    ),
    BusStation(
      id: '4',
      name: 'Gare de Bouaké',
      address: 'Centre-ville, Bouaké',
      city: 'Bouaké',
      facilities: [
        'Salle d\'attente',
        'Toilettes',
        'Café',
        'Billetterie',
        'Consigne',
        'WiFi'
      ],
      coordinates: const LatLng(7.6906, -5.0404),
      imageUrl: 'assets/images/bus_background.jpg',
    ),
    BusStation(
      id: '5',
      name: 'Gare de Korhogo',
      address: 'Centre-ville, Korhogo',
      city: 'Korhogo',
      facilities: ['Salle d\'attente', 'Toilettes', 'Distributeurs'],
      coordinates: const LatLng(9.4578, -5.6297),
      imageUrl: 'assets/images/bus_background.jpg',
    ),
    BusStation(
      id: '6',
      name: 'Gare de San Pedro',
      address: 'Centre-ville, San Pedro',
      city: 'San Pedro',
      facilities: ['Salle d\'attente', 'Toilettes', 'Café', 'Billetterie'],
      coordinates: const LatLng(4.7492, -6.6367),
      imageUrl: 'assets/images/bus_background.jpg',
    ),
    BusStation(
      id: '7',
      name: 'Gare de Daloa',
      address: 'Centre-ville, Daloa',
      city: 'Daloa',
      facilities: [
        'Salle d\'attente',
        'Toilettes',
        'Café',
        'Billetterie',
        'WiFi'
      ],
      coordinates: const LatLng(6.8775, -6.4444),
      imageUrl: 'assets/images/bus_background.jpg',
    ),
    BusStation(
      id: '8',
      name: 'Gare de Man',
      address: 'Centre-ville, Man',
      city: 'Man',
      facilities: [
        'Salle d\'attente',
        'Toilettes',
        'Café',
        'Billetterie',
        'Consigne',
        'WiFi'
      ],
      coordinates: const LatLng(7.4125, -7.5556),
      imageUrl: 'assets/images/bus_background.jpg',
    ),
    BusStation(
      id: '9',
      name: 'Gare de Gagnoa',
      address: 'Centre-ville, Gagnoa',
      city: 'Gagnoa',
      facilities: ['Salle d\'attente', 'Toilettes', 'Café', 'Billetterie'],
      coordinates: const LatLng(6.1319, -5.9506),
      imageUrl: 'assets/images/bus_background.jpg',
    ),
    BusStation(
      id: '10',
      name: 'Gare d\'Abengourou',
      address: 'Centre-ville, Abengourou',
      city: 'Abengourou',
      facilities: [
        'Salle d\'attente',
        'Toilettes',
        'Café',
        'Billetterie',
        'Consigne',
        'WiFi'
      ],
      coordinates: const LatLng(6.7297, -3.4964),
      imageUrl: 'assets/images/bus_background.jpg',
    ),
  ];

  final List<String> _cities = [
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

  String _selectedCity = 'Abidjan';

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStations() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _stations.clear();
        _stations.addAll([
          BusStation(
            id: '1',
            name: 'Gare d\'Adjamé',
            address: 'Adjamé, Abidjan',
            city: 'Abidjan',
            facilities: ['Parking', 'Toilettes', 'Café', 'Wifi'],
            coordinates: const LatLng(5.3667, -4.0167),
            imageUrl: 'assets/images/bus_background.jpg',
          ),
          BusStation(
            id: '2',
            name: 'Gare de Yopougon',
            address: 'Yopougon, Abidjan',
            city: 'Abidjan',
            facilities: ['Parking', 'Toilettes', 'Boutique'],
            coordinates: const LatLng(5.3333, -4.0667),
            imageUrl: 'assets/images/bus_background.jpg',
          ),
          BusStation(
            id: '3',
            name: 'Gare de Yamoussoukro',
            address: 'Centre-ville, Yamoussoukro',
            city: 'Yamoussoukro',
            facilities: ['Parking', 'Toilettes', 'Café', 'Wifi', 'Consigne'],
            coordinates: const LatLng(6.8276, -5.2893),
            imageUrl: 'assets/images/bus_background.jpg',
          ),
          BusStation(
            id: '4',
            name: 'Gare de Bouaké',
            address: 'Centre-ville, Bouaké',
            city: 'Bouaké',
            facilities: [
              'Salle d\'attente',
              'Toilettes',
              'Café',
              'Billetterie',
              'Consigne',
              'WiFi'
            ],
            coordinates: const LatLng(7.6906, -5.0404),
            imageUrl: 'assets/images/bus_background.jpg',
          ),
          BusStation(
            id: '5',
            name: 'Gare de Korhogo',
            address: 'Centre-ville, Korhogo',
            city: 'Korhogo',
            facilities: ['Salle d\'attente', 'Toilettes', 'Distributeurs'],
            coordinates: const LatLng(9.4578, -5.6297),
            imageUrl: 'assets/images/bus_background.jpg',
          ),
          BusStation(
            id: '6',
            name: 'Gare de San Pedro',
            address: 'Centre-ville, San Pedro',
            city: 'San Pedro',
            facilities: [
              'Salle d\'attente',
              'Toilettes',
              'Café',
              'Billetterie'
            ],
            coordinates: const LatLng(4.7492, -6.6367),
            imageUrl: 'assets/images/bus_background.jpg',
          ),
          BusStation(
            id: '7',
            name: 'Gare de Daloa',
            address: 'Centre-ville, Daloa',
            city: 'Daloa',
            facilities: [
              'Salle d\'attente',
              'Toilettes',
              'Café',
              'Billetterie',
              'WiFi'
            ],
            coordinates: const LatLng(6.8775, -6.4444),
            imageUrl: 'assets/images/bus_background.jpg',
          ),
          BusStation(
            id: '8',
            name: 'Gare de Man',
            address: 'Centre-ville, Man',
            city: 'Man',
            facilities: [
              'Salle d\'attente',
              'Toilettes',
              'Café',
              'Billetterie',
              'Consigne',
              'WiFi'
            ],
            coordinates: const LatLng(7.4125, -7.5556),
            imageUrl: 'assets/images/bus_background.jpg',
          ),
          BusStation(
            id: '9',
            name: 'Gare de Gagnoa',
            address: 'Centre-ville, Gagnoa',
            city: 'Gagnoa',
            facilities: [
              'Salle d\'attente',
              'Toilettes',
              'Café',
              'Billetterie'
            ],
            coordinates: const LatLng(6.1319, -5.9506),
            imageUrl: 'assets/images/bus_background.jpg',
          ),
          BusStation(
            id: '10',
            name: 'Gare d\'Abengourou',
            address: 'Centre-ville, Abengourou',
            city: 'Abengourou',
            facilities: [
              'Salle d\'attente',
              'Toilettes',
              'Café',
              'Billetterie',
              'Consigne',
              'WiFi'
            ],
            coordinates: const LatLng(6.7297, -3.4964),
            imageUrl: 'assets/images/bus_background.jpg',
          ),
        ]);
        _isLoading = false;
      });
    }
  }

  List<BusStation> get _filteredStations {
    return _stations.where((station) {
      final matchesCity = station.city == _selectedCity;
      final matchesSearch = _searchQuery.isEmpty ||
          station.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          station.address.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCity && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Stations'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCityFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStations.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredStations.length,
                        itemBuilder: (context, index) {
                          return _buildStationCard(_filteredStations[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryColor,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher des gares...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCityFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          final isSelected = city == _selectedCity;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(city),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCity = city;
                  });
                }
              },
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune gare trouvée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier votre recherche ou le filtre de ville',
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationCard(BusStation station) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: station.imageUrl.startsWith('http')
                ? Image.network(
                    station.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.directions_bus_filled,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                : Image.asset(
                    station.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        station.address,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: station.facilities
                      .take(3)
                      .map((facility) => _buildFacilityChip(facility))
                      .toList(),
                ),
                if (station.facilities.length > 3) ...[
                  const SizedBox(height: 8),
                  Text(
                    '+${station.facilities.length - 3} more facilities',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityChip(String facility) {
    IconData icon;
    switch (facility.toLowerCase()) {
      case 'waiting room':
        icon = Icons.chair;
        break;
      case 'restrooms':
        icon = Icons.wc;
        break;
      case 'cafe':
        icon = Icons.local_cafe;
        break;
      case 'ticket office':
        icon = Icons.confirmation_number;
        break;
      case 'luggage storage':
        icon = Icons.luggage;
        break;
      case 'wifi':
        icon = Icons.wifi;
        break;
      case 'vending machines':
        icon = Icons.local_drink;
        break;
      default:
        icon = Icons.check_circle;
    }

    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: AppTheme.primaryColor,
      ),
      label: Text(
        facility,
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
      backgroundColor: Colors.grey[100],
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showStationDetails(BusStation station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: station.imageUrl.startsWith('http')
                          ? Image.network(
                              station.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              station.imageUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              station.address,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Équipements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: station.facilities
                            .map((facility) => _buildFacilityChip(facility))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Localisation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.map,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Carte',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Lat: ${station.coordinates.latitude}, Long: ${station.coordinates.longitude}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Départs à venir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDepartureItem(
                        destination: 'Yamoussoukro',
                        time: '10:30',
                        platform: 'A1',
                        status: 'À l\'heure',
                      ),
                      _buildDepartureItem(
                        destination: 'Bouaké',
                        time: '11:15',
                        platform: 'B3',
                        status: 'Retard (15 min)',
                        isDelayed: true,
                      ),
                      _buildDepartureItem(
                        destination: 'San Pedro',
                        time: '12:45',
                        platform: 'C2',
                        status: 'À l\'heure',
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to search screen with this station
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('TROUVER DES BUS DEPUIS CETTE GARE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDepartureItem({
    required String destination,
    required String time,
    required String platform,
    required String status,
    bool isDelayed = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_bus,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Platform: $platform',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: isDelayed ? Colors.red : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BusStation {
  final String id;
  final String name;
  final String address;
  final String city;
  final List<String> facilities;
  final LatLng coordinates;
  final String imageUrl;

  BusStation({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.facilities,
    required this.coordinates,
    required this.imageUrl,
  });
}

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}
