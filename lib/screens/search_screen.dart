import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'bus_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _passengerCount = 1;
  bool _isAdvancedSearch = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  // Options de recherche avancée
  final List<String> _busTypes = ['Tous', 'Standard', 'Premium', 'VIP'];
  String _selectedBusType = 'Tous';

  final List<String> _departureTimeRanges = [
    'Toute heure',
    'Matin (6h-12h)',
    'Après-midi (12h-18h)',
    'Soir (18h-23h)',
    'Nuit (23h-6h)'
  ];
  String _selectedDepartureTime = 'Toute heure';

  final List<String> _sortOptions = [
    'Prix (croissant)',
    'Prix (décroissant)',
    'Durée (croissante)',
    'Durée (décroissante)',
    'Départ (plus tôt)',
    'Départ (plus tard)'
  ];
  String _selectedSortOption = 'Prix (croissant)';

  RangeValues _priceRange = const RangeValues(0, 100);

  final List<String> _amenities = [
    'WiFi',
    'Prises électriques',
    'Climatisation',
    'Toilettes',
    'Divertissement',
    'Collations'
  ];
  final List<bool> _selectedAmenities = [
    false,
    false,
    false,
    false,
    false,
    false
  ];

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

    // Construire les filtres de recherche avancée
    final Map<String, dynamic> advancedFilters = {
      'busType': _selectedBusType == 'Tous' ? null : _selectedBusType,
      'departureTimeRange': _selectedDepartureTime == 'Toute heure'
          ? null
          : _selectedDepartureTime,
      'sortOption': _selectedSortOption,
      'priceRange': _priceRange,
      'amenities': _selectedAmenities
          .asMap()
          .entries
          .where((entry) => entry.value)
          .map((entry) => _amenities[entry.key])
          .toList(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusResultsScreen(
          from: _fromController.text,
          to: _toController.text,
          date: _selectedDate,
          passengers: _passengerCount,
          advancedFilters: advancedFilters,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
        actions: [
          IconButton(
            icon: Icon(_isAdvancedSearch ? Icons.tune : Icons.tune_outlined),
            onPressed: () {
              setState(() {
                _isAdvancedSearch = !_isAdvancedSearch;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchCard(),
            if (_isAdvancedSearch) ...[
              const SizedBox(height: 24),
              _buildAdvancedSearchOptions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
    return TextField(
      controller: controller,
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
      ),
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

  Widget _buildAdvancedSearchOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Options de recherche avancée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownSelector(
              label: 'Type de bus',
              value: _selectedBusType,
              items: _busTypes,
              onChanged: (value) {
                setState(() {
                  _selectedBusType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownSelector(
              label: 'Heure de départ',
              value: _selectedDepartureTime,
              items: _departureTimeRanges,
              onChanged: (value) {
                setState(() {
                  _selectedDepartureTime = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownSelector(
              label: 'Trier par',
              value: _selectedSortOption,
              items: _sortOptions,
              onChanged: (value) {
                setState(() {
                  _selectedSortOption = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Fourchette de prix (€)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 100,
              divisions: 20,
              labels: RangeLabels(
                _priceRange.start.round().toString(),
                _priceRange.end.round().toString(),
              ),
              activeColor: AppTheme.primaryColor,
              inactiveColor: Colors.grey[300],
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Équipements',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                _amenities.length,
                (index) => FilterChip(
                  label: Text(_amenities[index]),
                  selected: _selectedAmenities[index],
                  onSelected: (selected) {
                    setState(() {
                      _selectedAmenities[index] = selected;
                    });
                  },
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedBusType = 'Tous';
                    _selectedDepartureTime = 'Toute heure';
                    _selectedSortOption = 'Prix (croissant)';
                    _priceRange = const RangeValues(0, 100);
                    for (int i = 0; i < _selectedAmenities.length; i++) {
                      _selectedAmenities[i] = false;
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('RÉINITIALISER LES FILTRES'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSelector({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 14,
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
