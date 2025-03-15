import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../screens/booking_screen.dart';
import '../screens/bus_tracking_screen.dart';
import '../screens/reviews_screen.dart';
import '../models/bus_route.dart';

class BusDetailsScreen extends StatefulWidget {
  final BusRoute busRoute;

  const BusDetailsScreen({
    Key? key,
    required this.busRoute,
  }) : super(key: key);

  @override
  State<BusDetailsScreen> createState() => _BusDetailsScreenState();
}

class _BusDetailsScreenState extends State<BusDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _busDetails;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBusDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBusDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final details = await _apiService.getBusDetails(widget.busRoute.id);
      setState(() {
        _busDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des détails: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    children: [
                      _buildHeader(),
                      _buildTabBar(),
                      _buildTabContent(),
                      _buildActionButtons(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '${widget.busRoute.fromLocation} → ${widget.busRoute.toLocation}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1000&q=80',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Partage non implémenté')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ajouté aux favoris')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final duration = widget.busRoute.getDurationInMinutes();
    final hours = duration ~/ 60;
    final minutes = duration % 60;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.busRoute.busCompany,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.busRoute.busType,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.busRoute.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeInfo(
                'Départ',
                widget.busRoute.departureTime,
                Icons.departure_board,
              ),
              _buildDurationInfo(hours, minutes),
              _buildTimeInfo(
                'Arrivée',
                widget.busRoute.arrivalTime,
                Icons.access_time,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                'Prix',
                '${widget.busRoute.price.toStringAsFixed(2)} €',
                Icons.euro,
              ),
              _buildInfoItem(
                'Places',
                '${widget.busRoute.availableSeats} disponibles',
                Icons.event_seat,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, DateTime time, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          '${time.day}/${time.month}/${time.year}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationInfo(int hours, int minutes) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 1,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 8),
        Text(
          hours > 0
              ? '$hours h ${minutes > 0 ? '$minutes min' : ''}'
              : '$minutes min',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 1,
          color: Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppTheme.primaryColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: AppTheme.primaryColor,
      tabs: const [
        Tab(text: 'DÉTAILS'),
        Tab(text: 'ÉQUIPEMENTS'),
        Tab(text: 'AVIS'),
      ],
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 300,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildAmenitiesTab(),
          _buildReviewsTab(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    if (_busDetails == null) {
      return const Center(child: Text('Aucun détail disponible'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem('Modèle', _busDetails!['model']),
          _buildDetailItem('Immatriculation', _busDetails!['licensePlate']),
          _buildDetailItem('Année', _busDetails!['year'].toString()),
          _buildDetailItem(
              'Nombre de sièges', _busDetails!['totalSeats'].toString()),
          _buildDetailItem('Dernière maintenance',
              _formatDate(_busDetails!['lastMaintenance'])),
          _buildDetailItem('Chauffeur', _busDetails!['driverName']),
          Row(
            children: [
              const Text(
                'Note du chauffeur: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 18,
              ),
              const SizedBox(width: 2),
              Text(
                _busDetails!['driverRating'].toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesTab() {
    final amenities = widget.busRoute.amenities;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Équipements à bord',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: amenities.map((amenity) {
              return _buildAmenityItem(amenity);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityItem(String amenity) {
    IconData icon;
    switch (amenity.toLowerCase()) {
      case 'wifi':
        icon = Icons.wifi;
        break;
      case 'usb':
        icon = Icons.usb;
        break;
      case 'toilet':
        icon = Icons.wc;
        break;
      case 'air conditioning':
        icon = Icons.ac_unit;
        break;
      case 'power outlets':
        icon = Icons.power;
        break;
      case 'entertainment':
        icon = Icons.tv;
        break;
      case 'snacks':
        icon = Icons.fastfood;
        break;
      case 'extra legroom':
        icon = Icons.airline_seat_legroom_extra;
        break;
      default:
        icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(amenity),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Avis des voyageurs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.busRoute.rating} (${(widget.busRoute.rating * 10).round()} avis)',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewsScreen(
                        routeName:
                            '${widget.busRoute.fromLocation} - ${widget.busRoute.toLocation}',
                        busNumber: widget.busRoute.id,
                      ),
                    ),
                  );
                },
                child: const Text('Voir tous les avis'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewItem(
            'Marie L.',
            4.5,
            'Voyage très confortable. Le chauffeur était professionnel et le bus était propre.',
            DateTime.now().subtract(const Duration(days: 5)),
          ),
          const Divider(),
          _buildReviewItem(
            'Thomas D.',
            5.0,
            'Excellent service! Le bus est parti à l\'heure et l\'équipage était très serviable.',
            DateTime.now().subtract(const Duration(days: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
      String name, double rating, String comment, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating.floor()
                    ? Icons.star
                    : (index < rating ? Icons.star_half : Icons.star_border),
                color: Colors.amber,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(comment),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusTrackingScreen(
                      busId: widget.busRoute.id,
                      routeFrom: widget.busRoute.fromLocation,
                      routeTo: widget.busRoute.toLocation,
                      departureTime: widget.busRoute.departureTime,
                      arrivalTime: widget.busRoute.arrivalTime,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.location_on),
              label: const Text('SUIVRE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(
                      busId: widget.busRoute.id,
                      routeFrom: widget.busRoute.fromLocation,
                      routeTo: widget.busRoute.toLocation,
                      departureTime: widget.busRoute.departureTime,
                      arrivalTime: widget.busRoute.arrivalTime,
                      price: widget.busRoute.price,
                      availableSeats: widget.busRoute.availableSeats,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.confirmation_number),
              label: const Text('RÉSERVER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
