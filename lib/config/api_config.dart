import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String get affiliateId => dotenv.env['AFFILIATE_ID'] ?? '';
  static const String baseUrl = 'https://bus-api.blablacar.com';
  static const String apiVersion = 'v3';
  static const String currency = 'EUR';
  static const String language = 'fr-FR';
}
