import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bus_tracking_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class BusTrackingListScreen extends StatefulWidget {
  const BusTrackingListScreen({Key? key}) : super(key: key);

  @override
  State<BusTrackingListScreen> createState() => _BusTrackingListScreenState();
}

class _BusTrackingListScreenState extends State<BusTrackingListScreen> {
  @override
  void initState() {
    super.initState();
    // S'assurer que le service de suivi des bus est initialisé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final busTrackingService =
          Provider.of<BusTrackingService>(context, listen: false);
      if (busTrackingService.getAllBusLocations().isEmpty) {
        busTrackingService.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (!authService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des Bus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final busTrackingService =
                  Provider.of<BusTrackingService>(context, listen: false);
              busTrackingService.initialize();
            },
          ),
        ],
      ),
      body: Consumer<BusTrackingService>(
        builder: (context, busTrackingService, child) {
          final busLocations = busTrackingService.getAllBusLocations();

          if (busLocations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des bus...'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: busLocations.length,
            itemBuilder: (context, index) {
              final busId = busLocations.keys.elementAt(index);
              final busLocation = busLocations[busId]!;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      busLocation.busName.substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    busLocation.busName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Statut: ${busLocation.status}'),
                      Text(
                        busLocation.delay > 0
                            ? 'Retard: ${busLocation.delay} minutes'
                            : 'À l\'heure',
                        style: TextStyle(
                          color: busLocation.delay > 0
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    // Récupérer les arrêts du bus
                    final stops = await busTrackingService.getBusStops(busId);
                    if (stops.isNotEmpty) {
                      // Naviguer vers l'écran de suivi détaillé
                      if (!mounted) return;
                      Navigator.pushNamed(
                        context,
                        '/bus_tracking_details',
                        arguments: {
                          'busId': busId,
                          'routeFrom': stops.first['city'],
                          'routeTo': stops.last['city'],
                          'departureTime': stops.first['departure_time'],
                          'arrivalTime': stops.last['arrival_time'],
                        },
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
