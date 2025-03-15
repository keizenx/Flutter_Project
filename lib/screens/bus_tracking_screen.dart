import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BusTrackingScreen extends StatefulWidget {
  final String busId;
  final String routeFrom;
  final String routeTo;
  final DateTime departureTime;
  final DateTime arrivalTime;

  const BusTrackingScreen({
    super.key,
    required this.busId,
    required this.routeFrom,
    required this.routeTo,
    required this.departureTime,
    required this.arrivalTime,
  });

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  late Timer _timer;
  bool _isLive = true;
  double _busProgress = 0.0;
  double _busSpeed = 0.0;
  int _estimatedMinutesLeft = 0;
  List<BusStop> _stops = [];
  int _currentStopIndex = 0;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
    _startTracking();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeTracking() {
    // Generate random stops between departure and arrival
    final totalDuration =
        widget.arrivalTime.difference(widget.departureTime).inMinutes;
    final numberOfStops = max(2,
        totalDuration ~/ 30); // At least 2 stops, roughly one every 30 minutes

    _stops = [
      BusStop(
        name: widget.routeFrom,
        time: widget.departureTime,
        isOrigin: true,
        isDestination: false,
      )
    ];

    // Generate intermediate stops for Ivorian context
    final ivorianStops = [
      'Yamoussoukro',
      'Bouaké',
      'San Pedro',
      'Korhogo',
      'Daloa',
      'Man',
      'Abengourou',
      'Divo',
      'Gagnoa',
      'Séguéla'
    ];

    // Generate intermediate stops
    for (int i = 1; i < numberOfStops - 1; i++) {
      final stopTime = widget.departureTime.add(
        Duration(minutes: (totalDuration * i / (numberOfStops - 1)).round()),
      );

      _stops.add(
        BusStop(
          name: ivorianStops[i % ivorianStops.length],
          time: stopTime,
          isOrigin: false,
          isDestination: false,
        ),
      );
    }

    _stops.add(
      BusStop(
        name: widget.routeTo,
        time: widget.arrivalTime,
        isOrigin: false,
        isDestination: true,
      ),
    );

    // Calculate initial progress
    _calculateProgress();
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isLive) {
        setState(() {
          // Simulate bus movement
          _busProgress = min(1.0, _busProgress + 0.01);
          _busSpeed =
              60 + (Random().nextDouble() * 20); // Between 60 and 80 km/h

          // Update estimated time
          _calculateProgress();

          // If bus has arrived, stop the timer
          if (_busProgress >= 1.0) {
            _timer.cancel();
          }
        });
      }
    });
  }

  void _calculateProgress() {
    final now = DateTime.now();
    final totalDuration =
        widget.arrivalTime.difference(widget.departureTime).inMinutes;

    if (now.isBefore(widget.departureTime)) {
      // Bus hasn't departed yet
      _busProgress = 0.0;
      _estimatedMinutesLeft = totalDuration;
      _currentStopIndex = 0;
    } else if (now.isAfter(widget.arrivalTime)) {
      // Bus has arrived
      _busProgress = 1.0;
      _estimatedMinutesLeft = 0;
      _currentStopIndex = _stops.length - 1;
    } else {
      // Bus is en route
      final elapsedMinutes = now.difference(widget.departureTime).inMinutes;
      _busProgress = elapsedMinutes / totalDuration;
      _estimatedMinutesLeft = totalDuration - elapsedMinutes;

      // Find current stop
      for (int i = 0; i < _stops.length - 1; i++) {
        if (now.isBefore(_stops[i + 1].time)) {
          _currentStopIndex = i;
          break;
        }
      }
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return '$hours h ${mins > 0 ? '$mins min' : ''}';
    } else {
      return '$mins min';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réserver ce bus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trajet: ${widget.routeFrom} → ${widget.routeTo}'),
            const SizedBox(height: 8),
            Text('Départ: ${_formatTime(widget.departureTime)}'),
            const SizedBox(height: 8),
            Text('Arrivée: ${_formatTime(widget.arrivalTime)}'),
            const SizedBox(height: 16),
            const Text('Nombre de passagers:'),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {},
                ),
                const Text('1'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Réservation effectuée avec succès!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('RÉSERVER'),
          ),
        ],
      ),
    );
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Position du bus partagée!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus ${widget.busId}'),
        actions: [
          Switch(
            value: _isLive,
            onChanged: (value) {
              setState(() {
                _isLive = value;
                if (_isLive) {
                  _startTracking();
                } else {
                  _timer.cancel();
                }
              });
            },
            activeColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.5),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          const Text(
            'EN DIRECT',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildMapSection(),
          _buildInfoSection(),
          _buildStopsSection(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _showBookingDialog,
                icon: const Icon(Icons.confirmation_number),
                label: const Text('RÉSERVER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _shareLocation,
                icon: const Icon(Icons.share),
                label: const Text('PARTAGER'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey[200],
      child: Stack(
        children: [
          // Placeholder for map
          Center(
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
              ],
            ),
          ),

          // Route line
          Positioned(
            left: 20,
            right: 20,
            top: 125,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Bus position
          Positioned(
            left: 20 + (MediaQuery.of(context).size.width - 40) * _busProgress,
            top: 115,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_bus,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),

          // Origin
          Positioned(
            left: 20,
            top: 125,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.routeFrom,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Destination
          Positioned(
            right: 20,
            top: 125,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.routeTo,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Temps estimé',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(_estimatedMinutesLeft),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Vitesse actuelle',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_busSpeed.toStringAsFixed(0)} km/h',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _busProgress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Départ: ${_formatTime(widget.departureTime)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Arrivée: ${_formatTime(widget.arrivalTime)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStopsSection() {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Arrêts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            if (_isExpanded)
              Expanded(
                child: ListView.builder(
                  itemCount: _stops.length,
                  itemBuilder: (context, index) {
                    final stop = _stops[index];
                    final isPast = index < _currentStopIndex;
                    final isCurrent = index == _currentStopIndex;
                    final isFuture = index > _currentStopIndex;

                    return ListTile(
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isPast
                              ? Colors.green
                              : isCurrent
                                  ? AppTheme.primaryColor
                                  : Colors.grey[300],
                          shape: BoxShape.circle,
                          border: isCurrent
                              ? Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                  width: 4,
                                )
                              : null,
                        ),
                        child: isPast
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      title: Text(
                        stop.name,
                        style: TextStyle(
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isFuture ? Colors.grey : Colors.black,
                        ),
                      ),
                      trailing: Text(
                        _formatTime(stop.time),
                        style: TextStyle(
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isFuture ? Colors.grey : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      width: 4,
                    ),
                  ),
                ),
                title: Text(
                  _stops[_currentStopIndex].name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  _formatTime(_stops[_currentStopIndex].time),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BusStop {
  final String name;
  final DateTime time;
  final bool isOrigin;
  final bool isDestination;

  BusStop({
    required this.name,
    required this.time,
    required this.isOrigin,
    required this.isDestination,
  });
}
