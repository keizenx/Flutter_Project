import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  // Flag pour indiquer si SMTP est supporté sur cette plateforme
  bool _isSmtpSupported = true;

  factory EmailService() => _instance;

  EmailService._internal();

  Future<SmtpServer?> _getSmtpServer() async {
    // Si nous savons déjà que SMTP n'est pas supporté, retourner null immédiatement
    if (!_isSmtpSupported) {
      return null;
    }

    try {
      final username = dotenv.env['SMTP_USERNAME'] ?? '';
      final password = dotenv.env['SMTP_PASSWORD'] ?? '';
      final host = dotenv.env['SMTP_HOST'] ?? 'smtp.gmail.com';
      final port = int.parse(dotenv.env['SMTP_PORT'] ?? '587');

      return SmtpServer(
        host,
        username: username,
        password: password,
        port: port,
        ssl: false,
        allowInsecure: false,
      );
    } catch (e) {
      print('Erreur lors de la création du serveur SMTP: $e');
      // Si l'erreur est liée aux sockets, marquer SMTP comme non supporté
      if (e.toString().contains('Socket constructor') ||
          e.toString().contains('Unsupported operation')) {
        print('SMTP n\'est pas supporté sur cette plateforme');
        _isSmtpSupported = false;
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> sendEmail({
    required String to,
    required String subject,
    required String text,
    required String html,
  }) async {
    try {
      // Vérifier si nous sommes sur le web, où SMTP n'est pas supporté
      if (kIsWeb) {
        _isSmtpSupported = false;
        return _handleFallbackEmail(to, subject, text, html);
      }

      final smtpServer = await _getSmtpServer();

      // Si le serveur SMTP est null, utiliser le mode de secours
      if (smtpServer == null) {
        return _handleFallbackEmail(to, subject, text, html);
      }

      final message = Message()
        ..from = Address(dotenv.env['SMTP_USERNAME'] ?? '', 'IvoireBus')
        ..recipients.add(to)
        ..subject = subject
        ..text = text
        ..html = html;

      try {
        final sendReport = await send(message, smtpServer);
        print('Email envoyé avec succès: ${sendReport.toString()}');
        return {
          'success': true,
          'message': 'Email envoyé avec succès',
          'report': sendReport.toString(),
        };
      } catch (smtpError) {
        // En cas d'erreur SMTP, on utilise un mode de secours
        print('Erreur SMTP, utilisation du mode de secours: $smtpError');

        // Si l'erreur est liée aux sockets, marquer SMTP comme non supporté
        if (smtpError.toString().contains('Socket constructor') ||
            smtpError.toString().contains('Unsupported operation')) {
          _isSmtpSupported = false;
        }

        return _handleFallbackEmail(to, subject, text, html);
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de l\'email: $e');
      return {
        'success': false,
        'message': 'Erreur lors de l\'envoi de l\'email: $e',
      };
    }
  }

  // Méthode pour gérer le mode de secours
  Future<Map<String, dynamic>> _handleFallbackEmail(
      String to, String subject, String text, String html) async {
    // Enregistrer l'email dans les logs pour référence
    print('Email (mode secours) à: $to');
    print('Sujet: $subject');
    print(
        'Contenu: ${text.substring(0, text.length > 100 ? 100 : text.length)}...');

    // Enregistrer l'email dans les préférences partagées pour référence future
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingEmails = prefs.getStringList('pending_emails') ?? [];

      final emailData = json.encode({
        'to': to,
        'subject': subject,
        'text': text,
        'html': html,
        'timestamp': DateTime.now().toIso8601String(),
      });

      pendingEmails.add(emailData);
      await prefs.setStringList('pending_emails', pendingEmails);

      print('Email enregistré dans les emails en attente pour envoi ultérieur');
    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'email en attente: $e');
    }

    // Simuler un délai d'envoi
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'success': true,
      'message': 'Email enregistré (mode secours)',
    };
  }

  Future<Map<String, dynamic>> sendBookingConfirmation({
    required String to,
    required String name,
    required String bookingReference,
    required String routeFrom,
    required String routeTo,
    required String departureTime,
    required String seatNumber,
    required double price,
  }) async {
    final subject = 'Confirmation de réservation - $bookingReference';

    final text = '''
Cher(e) $name,

Nous vous remercions d'avoir choisi IvoireBus pour votre voyage.

Votre réservation a été confirmée avec les détails suivants:

Référence de réservation: $bookingReference
Itinéraire: $routeFrom → $routeTo
Date et heure de départ: $departureTime
Numéro de siège: $seatNumber
Prix: ${price.toStringAsFixed(0)} FCFA

Veuillez vous présenter au moins 30 minutes avant l'heure de départ avec une pièce d'identité valide.

Pour toute question ou modification, veuillez nous contacter au +225 07 0123 4567 ou répondre à cet email.

Nous vous souhaitons un excellent voyage!

L'équipe IvoireBus
''';

    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Confirmation de réservation</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background-color: #FF6600; color: white; padding: 10px; text-align: center; }
    .content { padding: 20px; border: 1px solid #ddd; }
    .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #777; }
    .booking-details { background-color: #f9f9f9; padding: 15px; margin: 15px 0; border-left: 4px solid #FF6600; }
    .important { color: #FF6600; font-weight: bold; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>IvoireBus</h1>
    </div>
    <div class="content">
      <p>Cher(e) <strong>$name</strong>,</p>
      
      <p>Nous vous remercions d'avoir choisi IvoireBus pour votre voyage.</p>
      
      <p>Votre réservation a été confirmée avec les détails suivants:</p>
      
      <div class="booking-details">
        <p><strong>Référence de réservation:</strong> $bookingReference</p>
        <p><strong>Itinéraire:</strong> $routeFrom → $routeTo</p>
        <p><strong>Date et heure de départ:</strong> $departureTime</p>
        <p><strong>Numéro de siège:</strong> $seatNumber</p>
        <p><strong>Prix:</strong> ${price.toStringAsFixed(0)} FCFA</p>
      </div>
      
      <p class="important">Veuillez vous présenter au moins 30 minutes avant l'heure de départ avec une pièce d'identité valide.</p>
      
      <p>Pour toute question ou modification, veuillez nous contacter au +225 07 0123 4567 ou répondre à cet email.</p>
      
      <p>Nous vous souhaitons un excellent voyage!</p>
      
      <p>L'équipe IvoireBus</p>
    </div>
    <div class="footer">
      <p>© 2023 IvoireBus. Tous droits réservés.</p>
      <p>Abidjan, Côte d'Ivoire</p>
    </div>
  </div>
</body>
</html>
''';

    return await sendEmail(
      to: to,
      subject: subject,
      text: text,
      html: html,
    );
  }

  Future<Map<String, dynamic>> sendBusStatusUpdate({
    required String to,
    required String name,
    required String bookingReference,
    required String routeFrom,
    required String routeTo,
    required String departureTime,
    required String status,
    required String message,
  }) async {
    final subject = 'Mise à jour de votre voyage - $bookingReference';

    final text = '''
Cher(e) $name,

Nous souhaitons vous informer d'une mise à jour concernant votre réservation $bookingReference.

Détails de la réservation:
Itinéraire: $routeFrom → $routeTo
Date et heure de départ: $departureTime
Statut: $status

$message

Pour toute question, veuillez nous contacter au +225 07 0123 4567 ou répondre à cet email.

Nous vous remercions de votre compréhension.

L'équipe IvoireBus
''';

    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Mise à jour de votre voyage</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background-color: #FF6600; color: white; padding: 10px; text-align: center; }
    .content { padding: 20px; border: 1px solid #ddd; }
    .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #777; }
    .booking-details { background-color: #f9f9f9; padding: 15px; margin: 15px 0; border-left: 4px solid #FF6600; }
    .status { font-weight: bold; }
    .status.delayed { color: #FFA500; }
    .status.cancelled { color: #FF0000; }
    .status.on-time { color: #008000; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>IvoireBus</h1>
    </div>
    <div class="content">
      <p>Cher(e) <strong>$name</strong>,</p>
      
      <p>Nous souhaitons vous informer d'une mise à jour concernant votre réservation <strong>$bookingReference</strong>.</p>
      
      <div class="booking-details">
        <p><strong>Itinéraire:</strong> $routeFrom → $routeTo</p>
        <p><strong>Date et heure de départ:</strong> $departureTime</p>
        <p><strong>Statut:</strong> <span class="status ${status.toLowerCase() == 'retardé' ? 'delayed' : status.toLowerCase() == 'annulé' ? 'cancelled' : 'on-time'}">$status</span></p>
      </div>
      
      <p>$message</p>
      
      <p>Pour toute question, veuillez nous contacter au +225 07 0123 4567 ou répondre à cet email.</p>
      
      <p>Nous vous remercions de votre compréhension.</p>
      
      <p>L'équipe IvoireBus</p>
    </div>
    <div class="footer">
      <p>© 2023 IvoireBus. Tous droits réservés.</p>
      <p>Abidjan, Côte d'Ivoire</p>
    </div>
  </div>
</body>
</html>
''';

    return await sendEmail(
      to: to,
      subject: subject,
      text: text,
      html: html,
    );
  }

  Future<Map<String, dynamic>> sendPasswordReset({
    required String to,
    required String name,
    required String resetLink,
  }) async {
    final subject = 'Réinitialisation de votre mot de passe IvoireBus';

    final text = '''
Cher(e) $name,

Nous avons reçu une demande de réinitialisation de mot de passe pour votre compte IvoireBus.

Pour réinitialiser votre mot de passe, veuillez cliquer sur le lien ci-dessous:
$resetLink

Ce lien expirera dans 24 heures.

Si vous n'avez pas demandé cette réinitialisation, veuillez ignorer cet email ou nous contacter si vous avez des préoccupations.

L'équipe IvoireBus
''';

    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Réinitialisation de mot de passe</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background-color: #FF6600; color: white; padding: 10px; text-align: center; }
    .content { padding: 20px; border: 1px solid #ddd; }
    .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #777; }
    .button { display: inline-block; background-color: #FF6600; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin: 15px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>IvoireBus</h1>
    </div>
    <div class="content">
      <p>Cher(e) <strong>$name</strong>,</p>
      
      <p>Nous avons reçu une demande de réinitialisation de mot de passe pour votre compte IvoireBus.</p>
      
      <p>Pour réinitialiser votre mot de passe, veuillez cliquer sur le bouton ci-dessous:</p>
      
      <p style="text-align: center;">
        <a href="$resetLink" class="button">Réinitialiser mon mot de passe</a>
      </p>
      
      <p>Ou copiez et collez ce lien dans votre navigateur:</p>
      <p style="word-break: break-all;">$resetLink</p>
      
      <p>Ce lien expirera dans 24 heures.</p>
      
      <p>Si vous n'avez pas demandé cette réinitialisation, veuillez ignorer cet email ou nous contacter si vous avez des préoccupations.</p>
      
      <p>L'équipe IvoireBus</p>
    </div>
    <div class="footer">
      <p>© 2023 IvoireBus. Tous droits réservés.</p>
      <p>Abidjan, Côte d'Ivoire</p>
    </div>
  </div>
</body>
</html>
''';

    return await sendEmail(
      to: to,
      subject: subject,
      text: text,
      html: html,
    );
  }

  // Méthode pour tenter d'envoyer les emails en attente
  Future<Map<String, dynamic>> sendPendingEmails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingEmails = prefs.getStringList('pending_emails') ?? [];

      if (pendingEmails.isEmpty) {
        return {
          'success': true,
          'message': 'Aucun email en attente',
          'sent': 0,
          'failed': 0,
        };
      }

      int sent = 0;
      int failed = 0;
      final remainingEmails = <String>[];

      for (final emailJson in pendingEmails) {
        try {
          final emailData = json.decode(emailJson) as Map<String, dynamic>;

          final result = await sendEmail(
            to: emailData['to'] as String,
            subject: emailData['subject'] as String,
            text: emailData['text'] as String,
            html: emailData['html'] as String,
          );

          if (result['success']) {
            sent++;
          } else {
            failed++;
            remainingEmails.add(emailJson);
          }
        } catch (e) {
          print(
              'Erreur lors de la tentative d\'envoi d\'un email en attente: $e');
          failed++;
          remainingEmails.add(emailJson);
        }
      }

      // Mettre à jour la liste des emails en attente
      await prefs.setStringList('pending_emails', remainingEmails);

      return {
        'success': true,
        'message': 'Tentative d\'envoi des emails en attente terminée',
        'sent': sent,
        'failed': failed,
        'remaining': remainingEmails.length,
      };
    } catch (e) {
      print('Erreur lors de la tentative d\'envoi des emails en attente: $e');
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }
}
