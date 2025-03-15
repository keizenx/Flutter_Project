import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'models/bus_route.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/bus_results_screen.dart';
import 'screens/bus_details_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/ticket_screen.dart';
import 'screens/bus_tracking_screen.dart';
import 'screens/bus_tracking_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/stations_screen.dart';
import 'screens/promotions_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/booking_service.dart';
import 'services/bus_tracking_service.dart';
import 'services/email_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement
  await dotenv.load(fileName: '.env');

  // Définir l'orientation de l'application
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialiser les services
  final databaseService = DatabaseService();
  await databaseService.prefs;

  final authService = AuthService();
  await authService.initialize();

  final bookingService = BookingService();
  final emailService = EmailService();
  final busTrackingService = BusTrackingService();
  await busTrackingService.initialize();

  // Initialiser les préférences partagées
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(isDarkMode),
        ),
        ChangeNotifierProvider<AuthService>.value(
          value: authService,
        ),
        Provider<DatabaseService>.value(
          value: databaseService,
        ),
        Provider<BookingService>.value(
          value: bookingService,
        ),
        Provider<EmailService>.value(
          value: emailService,
        ),
        ChangeNotifierProvider<BusTrackingService>.value(
          value: busTrackingService,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;

  ThemeProvider(this._isDarkMode);

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData =>
      _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    // Sauvegarder la préférence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);

    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'IvoireBus',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          initialRoute: authService.isAuthenticated ? '/' : '/login',
          routes: {
            '/': (context) => const MainScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/search': (context) => const SearchScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/stations': (context) => const StationsScreen(),
            '/promotions': (context) => const PromotionsScreen(),
            '/history': (context) => const TravelHistoryScreen(),
            '/bus_tracking': (context) => const BusTrackingListScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/bus_details') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => BusDetailsScreen(
                  busRoute: BusRoute(
                    id: args['busId'] as String,
                    fromLocation: args['routeFrom'] as String,
                    toLocation: args['routeTo'] as String,
                    departureTime: args['departureTime'] as DateTime,
                    arrivalTime: args['arrivalTime'] as DateTime,
                    price: args['price'] as double,
                    busCompany: args['busCompany'] as String? ?? 'IvoireBus',
                    busType: args['busType'] as String? ?? 'Standard',
                    availableSeats: args['availableSeats'] as int? ?? 45,
                    amenities: args['amenities'] as List<String>? ??
                        ['Climatisation', 'WiFi'],
                    rating: args['rating'] as double? ?? 4.5,
                  ),
                ),
              );
            } else if (settings.name == '/booking') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => BookingScreen(
                  busId: args['busId'] as String,
                  routeFrom: args['routeFrom'] as String,
                  routeTo: args['routeTo'] as String,
                  departureTime: args['departureTime'] as DateTime,
                  arrivalTime: args['arrivalTime'] as DateTime,
                  price: args['price'] as double,
                  availableSeats: args['availableSeats'] as int,
                ),
              );
            } else if (settings.name == '/ticket') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => TicketScreen(
                  bookingReference: args['bookingReference'] as String,
                  route: args['route'] as String,
                  date: args['date'] as String,
                  departureTime: args['departureTime'] as String,
                  seatNumber: args['seatNumber'] as int,
                  passengerName: args['passengerName'] as String,
                ),
              );
            } else if (settings.name == '/bus_tracking_details') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => BusTrackingScreen(
                  busId: args['busId'] as String,
                  routeFrom: args['routeFrom'] as String,
                  routeTo: args['routeTo'] as String,
                  departureTime: args['departureTime'] as DateTime,
                  arrivalTime: args['arrivalTime'] as DateTime,
                ),
              );
            }
            return null;
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Page non trouvée'),
                ),
                body: const Center(
                  child: Text('La page demandée n\'existe pas.'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const TicketScreen(
      bookingReference: 'IB12345678',
      route: 'Abidjan → Yamoussoukro',
      date: '15 Juin 2023',
      departureTime: '10:30',
      seatNumber: 12,
      passengerName: 'Kouassi Georges',
    ),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// Écran d'historique de voyage temporaire
class TravelHistoryScreen extends StatelessWidget {
  const TravelHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final bookingService = Provider.of<BookingService>(context);

    if (!authService.isAuthenticated || authService.currentUser == null) {
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
        title: const Text('Historique de voyage'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: bookingService
            .getUserBookings(authService.currentUser!['id'] as String),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(
              child: Text('Aucun voyage trouvé dans votre historique.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final departureTime =
                  DateTime.parse(booking['departure_time'] as String);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.directions_bus, color: Colors.white),
                  ),
                  title: Text(
                    '${booking['route_from']} → ${booking['route_to']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${departureTime.day}/${departureTime.month}/${departureTime.year} - ${departureTime.hour}:${departureTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: Text(
                    '${booking['price']} FCFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  onTap: () {
                    // Afficher les détails du ticket
                    Navigator.pushNamed(
                      context,
                      '/ticket',
                      arguments: {
                        'bookingReference': booking['booking_reference'],
                        'route':
                            '${booking['route_from']} → ${booking['route_to']}',
                        'date':
                            '${departureTime.day}/${departureTime.month}/${departureTime.year}',
                        'departureTime':
                            '${departureTime.hour}:${departureTime.minute.toString().padLeft(2, '0')}',
                        'seatNumber': booking['seat_number'],
                        'passengerName':
                            authService.currentUser!['name'] as String,
                      },
                    );
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
