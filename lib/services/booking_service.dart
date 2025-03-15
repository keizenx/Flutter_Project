import 'dart:math';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../services/email_service.dart';
import 'dart:convert';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  final DatabaseService _databaseService = DatabaseService();
  final EmailService _emailService = EmailService();

  factory BookingService() => _instance;

  BookingService._internal();

  // Générer une référence de réservation unique
  String _generateBookingReference() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final result = StringBuffer('IB');

    for (var i = 0; i < 8; i++) {
      result.write(chars[random.nextInt(chars.length)]);
    }

    return result.toString();
  }

  // Créer une nouvelle réservation
  Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String busId,
    required String routeFrom,
    required String routeTo,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required int seatNumber,
    required double price,
    required String paymentMethod,
  }) async {
    try {
      final bookingReference = _generateBookingReference();

      final bookingData = {
        'user_id': userId,
        'bus_id': busId,
        'route_from': routeFrom,
        'route_to': routeTo,
        'departure_time': departureTime.toIso8601String(),
        'arrival_time': arrivalTime.toIso8601String(),
        'seat_number': seatNumber,
        'price': price,
        'booking_reference': bookingReference,
        'status': 'confirmed', // confirmed, cancelled, completed
        'payment_method': paymentMethod,
      };

      final bookingId = await _databaseService.insertBooking(bookingData);

      if (bookingId.isNotEmpty) {
        // Récupérer les informations de l'utilisateur pour l'email
        final sp = await _databaseService.prefs;
        final users = jsonDecode(sp.getString('users') ?? '[]') as List;
        final userList = users
            .where((user) => user['id'].toString() == userId.toString())
            .toList();

        if (userList.isNotEmpty) {
          final user = userList.first;
          final userName = user['name'] as String;
          final userEmail = user['email'] as String;

          // Envoyer l'email de confirmation
          try {
            final emailResult = await _emailService.sendBookingConfirmation(
              to: userEmail,
              name: userName,
              bookingReference: bookingReference,
              routeFrom: routeFrom,
              routeTo: routeTo,
              departureTime:
                  DateFormat('dd/MM/yyyy HH:mm').format(departureTime),
              seatNumber: seatNumber.toString(),
              price: price,
            );

            print('Statut d\'envoi de l\'email: ${emailResult['success']}');
          } catch (emailError) {
            // Ne pas échouer la réservation si l'email échoue
            print(
                'Erreur lors de l\'envoi de l\'email de confirmation: $emailError');
          }
        }

        return {
          'success': true,
          'message': 'Réservation créée avec succès',
          'booking_reference': bookingReference,
        };
      }

      return {
        'success': false,
        'message': 'Erreur lors de la création de la réservation',
      };
    } catch (e) {
      print('Erreur détaillée lors de la création de réservation: $e');
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Récupérer les réservations d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      return await _databaseService.getBookingsByUserId(userId);
    } catch (e) {
      print('Erreur lors de la récupération des réservations: $e');
      return [];
    }
  }

  // Récupérer une réservation par sa référence
  Future<Map<String, dynamic>?> getBookingByReference(String reference) async {
    try {
      return await _databaseService.getBookingByReference(reference);
    } catch (e) {
      print('Erreur lors de la récupération de la réservation: $e');
      return null;
    }
  }

  // Annuler une réservation
  Future<Map<String, dynamic>> cancelBooking(String reference) async {
    try {
      final booking = await _databaseService.getBookingByReference(reference);

      if (booking == null) {
        return {
          'success': false,
          'message': 'Réservation non trouvée',
        };
      }

      final result =
          await _databaseService.updateBookingStatus(reference, 'cancelled');

      if (result > 0) {
        // Récupérer les informations de l'utilisateur pour l'email
        final sp = await _databaseService.prefs;
        final users = jsonDecode(sp.getString('users') ?? '[]') as List;
        final userList = users
            .where((user) =>
                user['id'].toString() == booking['user_id'].toString())
            .toList();

        if (userList.isNotEmpty) {
          final user = userList.first;
          final userName = user['name'] as String;
          final userEmail = user['email'] as String;

          // Envoyer l'email d'annulation
          try {
            final emailResult = await _emailService.sendBusStatusUpdate(
              to: userEmail,
              name: userName,
              bookingReference: reference,
              routeFrom: booking['route_from'] as String,
              routeTo: booking['route_to'] as String,
              departureTime: DateFormat('dd/MM/yyyy HH:mm')
                  .format(DateTime.parse(booking['departure_time'] as String)),
              status: 'Annulé',
              message:
                  'Votre réservation a été annulée avec succès. Le remboursement sera traité dans les 5 à 7 jours ouvrables.',
            );

            print(
                'Statut d\'envoi de l\'email d\'annulation: ${emailResult['success']}');
          } catch (emailError) {
            // Ne pas échouer l'annulation si l'email échoue
            print(
                'Erreur lors de l\'envoi de l\'email d\'annulation: $emailError');
          }
        }

        return {
          'success': true,
          'message': 'Réservation annulée avec succès',
        };
      }

      return {
        'success': false,
        'message': 'Erreur lors de l\'annulation de la réservation',
      };
    } catch (e) {
      print('Erreur détaillée lors de l\'annulation de réservation: $e');
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Ajouter un itinéraire aux favoris
  Future<Map<String, dynamic>> addFavoriteRoute({
    required String userId,
    required String routeFrom,
    required String routeTo,
  }) async {
    try {
      final routeData = {
        'user_id': userId,
        'route_from': routeFrom,
        'route_to': routeTo,
      };

      final routeId = await _databaseService.insertFavoriteRoute(routeData);

      if (routeId.isNotEmpty) {
        return {
          'success': true,
          'message': 'Itinéraire ajouté aux favoris',
        };
      }

      return {
        'success': false,
        'message': 'Erreur lors de l\'ajout de l\'itinéraire aux favoris',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Récupérer les itinéraires favoris d'un utilisateur
  Future<List<Map<String, dynamic>>> getFavoriteRoutes(String userId) async {
    try {
      return await _databaseService.getFavoriteRoutesByUserId(userId);
    } catch (e) {
      print('Erreur lors de la récupération des itinéraires favoris: $e');
      return [];
    }
  }
}
