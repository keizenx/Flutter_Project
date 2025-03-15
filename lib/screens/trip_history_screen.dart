import 'package:flutter/material.dart';
import '../models/bus_route.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Remplacer par la vraie liste
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.directions_bus),
              ),
              title: Text('Paris → Lyon'),
              subtitle: Text('March 15, 2024 - 14:30'),
              trailing: const Text(
                '€25.00',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Navigation vers les détails du voyage
              },
            ),
          );
        },
      ),
    );
  }
}
