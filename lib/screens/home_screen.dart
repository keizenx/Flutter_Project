import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../screens/bus_results_screen.dart';
import '../screens/promotions_screen.dart';
import '../screens/stations_screen.dart';
import '../screens/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _passengerCount = 1;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _popularDestinations = [
    {
      'from': 'Abidjan',
      'to': 'Yamoussoukro',
      'image': 'assets/images/bus_background.jpg',
      'price': 5000,
    },
    {
      'from': 'Bouaké',
      'to': 'San Pedro',
      'image': 'assets/images/bus_background.jpg',
      'price': 7500,
    },
    {
      'from': 'Korhogo',
      'to': 'Abidjan',
      'image': 'assets/images/bus_background.jpg',
      'price': 8000,
    },
    {
      'from': 'Man',
      'to': 'Daloa',
      'image': 'assets/images/bus_background.jpg',
      'price': 4500,
    },
  ];

  final List<Map<String, dynamic>> _recentSearches = [];

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _swapLocations() {
    setState(() {
      final temp = _fromController.text;
      _fromController.text = _toController.text;
      _toController.text = temp;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showPassengerSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Nombre de passagers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _passengerCount > 1
                            ? () {
                                setModalState(() {
                                  setState(() {
                                    _passengerCount--;
                                  });
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: _passengerCount > 1
                            ? AppTheme.primaryColor
                            : Colors.grey,
                        iconSize: 36,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _passengerCount.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _passengerCount < 10
                            ? () {
                                setModalState(() {
                                  setState(() {
                                    _passengerCount++;
                                  });
                                });
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                        color: _passengerCount < 10
                            ? AppTheme.primaryColor
                            : Colors.grey,
                        iconSize: 36,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Confirmer'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _searchBuses() {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir les lieux de départ et d\'arrivée'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ajouter à l'historique de recherche
    final search = {
      'from': _fromController.text,
      'to': _toController.text,
      'date': _selectedDate,
      'passengers': _passengerCount,
    };

    if (!_recentSearches.any((element) =>
        element['from'] == search['from'] && element['to'] == search['to'])) {
      setState(() {
        _recentSearches.insert(0, search);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusResultsScreen(
          from: _fromController.text,
          to: _toController.text,
          date: _selectedDate,
          passengers: _passengerCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchCard(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Destinations populaires', 'Voir tout',
                      () {
                    // Navigation vers la liste complète des destinations
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StationsScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildPopularDestinations(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Offres spéciales', 'Voir tout', () {
                    // Navigation vers la liste complète des promotions
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PromotionsScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildSpecialOffers(),
                  if (_recentSearches.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Recherches récentes', 'Effacer', () {
                      setState(() {
                        _recentSearches.clear();
                      });
                    }),
                    const SizedBox(height: 16),
                    _buildRecentSearches(),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'IvoireBus',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange,
                Colors.green,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLocationInput(
              controller: _fromController,
              label: 'Départ',
              icon: Icons.location_on,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.swap_vert,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  onPressed: _swapLocations,
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildLocationInput(
              controller: _toController,
              label: 'Arrivée',
              icon: Icons.location_on,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPassengerSelector(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _searchBuses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'RECHERCHER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    // Liste des villes populaires pour les suggestions
    final List<String> suggestions = [
      'Abidjan',
      'Yamoussoukro',
      'Bouaké',
      'Korhogo',
      'San Pedro',
      'Daloa',
      'Man',
      'Gagnoa',
      'Abengourou',
      'Divo',
    ];

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return suggestions.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        // Synchroniser le controller externe avec celui de l'Autocomplete
        if (controller.text.isNotEmpty && fieldController.text.isEmpty) {
          fieldController.text = controller.text;
        }

        return TextField(
          controller: fieldController,
          focusNode: fieldFocusNode,
          onChanged: (value) {
            controller.text = value;
          },
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(
              icon,
              color: color,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                fieldController.clear();
                controller.clear();
              },
            ),
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    leading: Icon(
                      Icons.location_city,
                      color: color,
                    ),
                    title: Text(option),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                DateFormat('dd MMM yyyy').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerSelector() {
    return InkWell(
      onTap: _showPassengerSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$_passengerCount ${_passengerCount > 1 ? 'passagers' : 'passager'}',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, String actionText, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: TextStyle(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularDestinations() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _popularDestinations.length,
        itemBuilder: (context, index) {
          final destination = _popularDestinations[index];
          return _buildDestinationCard(
            from: destination['from'],
            to: destination['to'],
            imageUrl: destination['image'],
            price: destination['price'],
          );
        },
      ),
    );
  }

  Widget _buildDestinationCard({
    required String from,
    required String to,
    required String imageUrl,
    required double price,
  }) {
    return GestureDetector(
      onTap: () {
        // Naviguer vers l'écran de résultats de bus avec les détails de la destination
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusResultsScreen(
              from: from,
              to: to,
              date: DateTime.now().add(const Duration(days: 1)),
              passengers: 1,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.directions_bus,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      imageUrl,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$from → $to',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'À partir de ${price.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialOffers() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange,
            Colors.green,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.local_offer,
              size: 150,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'OFFRE SPÉCIALE',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '30% de réduction pour la fête de l\'indépendance',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Utilisez le code: IVOIRE30',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PromotionsScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('En profiter'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      children: _recentSearches.map((search) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.history),
            title: Text('${search['from']} → ${search['to']}'),
            subtitle: Text(
              '${DateFormat('dd MMM yyyy').format(search['date'])} · ${search['passengers']} ${search['passengers'] > 1 ? 'passagers' : 'passager'}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {
                setState(() {
                  _fromController.text = search['from'];
                  _toController.text = search['to'];
                  _selectedDate = search['date'];
                  _passengerCount = search['passengers'];
                });
                _searchBuses();
              },
            ),
            onTap: () {
              setState(() {
                _fromController.text = search['from'];
                _toController.text = search['to'];
                _selectedDate = search['date'];
                _passengerCount = search['passengers'];
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionItem(
              icon: Icons.confirmation_number,
              label: 'Réserver',
              color: Colors.blue,
              onTap: () {
                // Ouvrir directement la page de réservation avec une destination populaire
                final popularDestination = _popularDestinations[
                    0]; // Prendre la première destination populaire
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusResultsScreen(
                      from: popularDestination['from'],
                      to: popularDestination['to'],
                      date: DateTime.now().add(const Duration(days: 1)),
                      passengers: 1,
                    ),
                  ),
                );
              },
            ),
            _buildQuickActionItem(
              icon: Icons.location_on,
              label: 'Suivre',
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/bus_tracking');
              },
            ),
            _buildQuickActionItem(
              icon: Icons.local_offer,
              label: 'Promos',
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/promotions');
              },
            ),
            _buildQuickActionItem(
              icon: Icons.history,
              label: 'Historique',
              color: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
