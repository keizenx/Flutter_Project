import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/ticket_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final String bookingId;
  final String busId;
  final String routeFrom;
  final String routeTo;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final List<int> seats;
  final String passengerName;
  final String passengerEmail;
  final String passengerPhone;
  final double price;

  const ConfirmationScreen({
    Key? key,
    required this.bookingId,
    required this.busId,
    required this.routeFrom,
    required this.routeTo,
    required this.departureTime,
    required this.arrivalTime,
    required this.seats,
    required this.passengerName,
    required this.passengerEmail,
    required this.passengerPhone,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'Réservation confirmée !',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Votre réservation a été effectuée avec succès.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildInfoCard(context),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketScreen(
                            bookingReference: bookingId,
                            route: '$routeFrom → $routeTo',
                            date:
                                '${departureTime.day}/${departureTime.month}/${departureTime.year}',
                            departureTime:
                                '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}',
                            seatNumber: seats.first,
                            passengerName: passengerName,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Voir mon billet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Référence', bookingId),
            const Divider(),
            _buildInfoRow('Trajet', '$routeFrom → $routeTo'),
            const Divider(),
            _buildInfoRow('Date',
                '${departureTime.day}/${departureTime.month}/${departureTime.year}'),
            const Divider(),
            _buildInfoRow('Départ',
                '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}'),
            const Divider(),
            _buildInfoRow('Arrivée',
                '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}'),
            const Divider(),
            _buildInfoRow(
                'Siège(s)', seats.map((s) => s.toString()).join(', ')),
            const Divider(),
            _buildInfoRow('Passager', passengerName),
            const Divider(),
            _buildInfoRow('Email', passengerEmail),
            const Divider(),
            _buildInfoRow('Téléphone', passengerPhone),
            const Divider(),
            _buildInfoRow('Prix total', '${price * seats.length} FCFA'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
