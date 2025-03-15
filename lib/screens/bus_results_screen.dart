import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BusResultsScreen extends StatefulWidget {
  final String from;
  final String to;
  final DateTime date;
  final int passengers;
  final Map<String, dynamic>? advancedFilters;

  const BusResultsScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.passengers,
    this.advancedFilters,
  });

  @override
  State<BusResultsScreen> createState() => _BusResultsScreenState();
}

class _BusResultsScreenState extends State<BusResultsScreen> {
  bool _isLoading = true;
  List<BusTrip> _trips = [];
  List<BusTrip> _filteredTrips = [];

  // Filter states
  RangeValues _priceRange = const RangeValues(0, 200);
  RangeValues _timeRange = const RangeValues(0, 24);
  List<String> _selectedBusTypes = [];
  List<String> _selectedAmenities = [];
  String _sortBy = 'departure'; // 'departure', 'duration', 'price'

  final List<String> _busTypes = ['Standard', 'Express', 'Luxury', 'Sleeper'];
  final List<String> _amenities = [
    'WiFi',
    'Power Outlets',
    'Toilet',
    'Air Conditioning',
    'Snacks',
    'Entertainment'
  ];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _trips = _generateMockTrips();
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  List<BusTrip> _generateMockTrips() {
    final List<BusTrip> trips = [];
    final now = DateTime.now();

    // Generate 15 mock trips
    for (int i = 0; i < 15; i++) {
      final departureTime = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        6 + (i % 18), // Between 6 AM and 11 PM
        (i * 7) % 60,
      );

      final durationMinutes = 120 + (i * 30) % 240; // Between 2 and 6 hours
      final arrivalTime = departureTime.add(Duration(minutes: durationMinutes));

      final price = 20.0 + (i * 5.5) % 180; // Between 20 and 200 EUR
      final availableSeats = 5 + (i * 3) % 46; // Between 5 and 50 seats

      final busType = _busTypes[i % _busTypes.length];
      final busCompany =
          ['FlixBus', 'BlaBlaBus', 'Eurolines', 'Ouibus', 'Alsa'][i % 5];

      final List<String> tripAmenities = [];
      for (int j = 0; j < _amenities.length; j++) {
        if ((i + j) % 3 == 0) {
          // Randomly select amenities
          tripAmenities.add(_amenities[j]);
        }
      }

      trips.add(BusTrip(
        id: 'TRIP${i.toString().padLeft(3, '0')}',
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        from: widget.from,
        to: widget.to,
        price: price,
        busCompany: busCompany,
        busType: busType,
        availableSeats: availableSeats,
        amenities: tripAmenities,
        rating: 3.5 + (i % 3) * 0.5, // Between 3.5 and 5.0
      ));
    }

    return trips;
  }

  void _applyFilters() {
    setState(() {
      _filteredTrips = _trips.where((trip) {
        // Apply price filter
        if (trip.price < _priceRange.start || trip.price > _priceRange.end) {
          return false;
        }

        // Apply time filter
        final hour = trip.departureTime.hour.toDouble();
        if (hour < _timeRange.start || hour > _timeRange.end) {
          return false;
        }

        // Apply bus type filter
        if (_selectedBusTypes.isNotEmpty &&
            !_selectedBusTypes.contains(trip.busType)) {
          return false;
        }

        // Apply amenities filter
        if (_selectedAmenities.isNotEmpty) {
          for (final amenity in _selectedAmenities) {
            if (!trip.amenities.contains(amenity)) {
              return false;
            }
          }
        }

        return true;
      }).toList();

      // Apply sorting
      _sortTrips();
    });
  }

  void _sortTrips() {
    switch (_sortBy) {
      case 'departure':
        _filteredTrips
            .sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
      case 'duration':
        _filteredTrips
            .sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
        break;
      case 'price':
        _filteredTrips.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'rating':
        _filteredTrips.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Results',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _priceRange = const RangeValues(0, 200);
                                _timeRange = const RangeValues(0, 24);
                                _selectedBusTypes = [];
                                _selectedAmenities = [];
                              });
                            },
                            child: const Text('Reset All'),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Price Range
                      const Text(
                        'Price Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 200,
                        divisions: 20,
                        labels: RangeLabels(
                          '€${_priceRange.start.round()}',
                          '€${_priceRange.end.round()}',
                        ),
                        onChanged: (values) {
                          setModalState(() {
                            _priceRange = values;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('€${_priceRange.start.round()}'),
                          Text('€${_priceRange.end.round()}'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Departure Time Range
                      const Text(
                        'Departure Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: _timeRange,
                        min: 0,
                        max: 24,
                        divisions: 24,
                        labels: RangeLabels(
                          _formatHour(_timeRange.start.round()),
                          _formatHour(_timeRange.end.round()),
                        ),
                        onChanged: (values) {
                          setModalState(() {
                            _timeRange = values;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatHour(_timeRange.start.round())),
                          Text(_formatHour(_timeRange.end.round())),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Bus Type
                      const Text(
                        'Bus Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _busTypes.map((type) {
                          final isSelected = _selectedBusTypes.contains(type);
                          return FilterChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  _selectedBusTypes.add(type);
                                } else {
                                  _selectedBusTypes.remove(type);
                                }
                              });
                            },
                            selectedColor:
                                AppTheme.primaryColor.withOpacity(0.2),
                            checkmarkColor: AppTheme.primaryColor,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Amenities
                      const Text(
                        'Amenities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _amenities.map((amenity) {
                          final isSelected =
                              _selectedAmenities.contains(amenity);
                          return FilterChip(
                            label: Text(amenity),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  _selectedAmenities.add(amenity);
                                } else {
                                  _selectedAmenities.remove(amenity);
                                }
                              });
                            },
                            selectedColor:
                                AppTheme.primaryColor.withOpacity(0.2),
                            checkmarkColor: AppTheme.primaryColor,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // Apply Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0 || hour == 24) {
      return '12 AM';
    } else if (hour == 12) {
      return '12 PM';
    } else if (hour < 12) {
      return '$hour AM';
    } else {
      return '${hour - 12} PM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.from} to ${widget.to}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_formatDate(widget.date)} · ${widget.passengers} ${widget.passengers > 1 ? 'Passengers' : 'Passenger'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSortBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTrips.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTrips.length,
                        itemBuilder: (context, index) {
                          return _buildTripCard(_filteredTrips[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          Text(
            '${_filteredTrips.length} ${_filteredTrips.length == 1 ? 'result' : 'results'}',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Text('Sort by:'),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            items: [
              DropdownMenuItem(
                value: 'departure',
                child: const Text('Departure'),
              ),
              DropdownMenuItem(
                value: 'duration',
                child: const Text('Duration'),
              ),
              DropdownMenuItem(
                value: 'price',
                child: const Text('Price'),
              ),
              DropdownMenuItem(
                value: 'rating',
                child: const Text('Rating'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _sortBy = value;
                  _sortTrips();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No trips found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filters or search criteria',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.search),
            label: const Text('New Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BusTrip trip) {
    final duration = trip.durationMinutes;
    final hours = duration ~/ 60;
    final minutes = duration % 60;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Company and rating
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          trip.busCompany.substring(0, 2),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.busCompany,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          trip.busType,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trip.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Trip details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Time and locations
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTime(trip.departureTime),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                trip.from,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '$hours h ${minutes > 0 ? '$minutes m' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: 1,
                                      color: Colors.grey[300],
                                    ),
                                    const Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTime(trip.arrivalTime),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                trip.to,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildAmenityIcon(Icons.wifi, 'WiFi',
                              trip.amenities.contains('WiFi')),
                          _buildAmenityIcon(Icons.power, 'Power',
                              trip.amenities.contains('Power Outlets')),
                          _buildAmenityIcon(Icons.wc, 'Toilet',
                              trip.amenities.contains('Toilet')),
                          _buildAmenityIcon(Icons.ac_unit, 'AC',
                              trip.amenities.contains('Air Conditioning')),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: trip.availableSeats < 10
                                  ? Colors.red[50]
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: trip.availableSeats < 10
                                    ? Colors.red
                                    : Colors.green,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${trip.availableSeats} seats left',
                              style: TextStyle(
                                fontSize: 12,
                                color: trip.availableSeats < 10
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Price and buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '€${trip.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      'per passenger',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to bus tracking screen
                    Navigator.pushNamed(
                      context,
                      '/bus_tracking_details',
                      arguments: {
                        'busId': trip.id,
                        'routeFrom': trip.from,
                        'routeTo': trip.to,
                        'departureTime': trip.departureTime,
                        'arrivalTime': trip.arrivalTime,
                      },
                    );
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('TRACK'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to booking screen
                    Navigator.pushNamed(
                      context,
                      '/booking',
                      arguments: {
                        'busId': trip.id,
                        'routeFrom': trip.from,
                        'routeTo': trip.to,
                        'departureTime': trip.departureTime,
                        'arrivalTime': trip.arrivalTime,
                        'price': trip.price,
                        'availableSeats': trip.availableSeats,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('BOOK'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityIcon(IconData icon, String label, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: isAvailable ? AppTheme.primaryColor : Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isAvailable ? Colors.black : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}

class BusTrip {
  final String id;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String from;
  final String to;
  final double price;
  final String busCompany;
  final String busType;
  final int availableSeats;
  final List<String> amenities;
  final double rating;

  BusTrip({
    required this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.from,
    required this.to,
    required this.price,
    required this.busCompany,
    required this.busType,
    required this.availableSeats,
    required this.amenities,
    required this.rating,
  });

  int get durationMinutes => arrivalTime.difference(departureTime).inMinutes;
}
