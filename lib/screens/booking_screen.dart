import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../screens/ticket_screen.dart';
import '../screens/confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final String busId;
  final String routeFrom;
  final String routeTo;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final int availableSeats;

  const BookingScreen({
    super.key,
    required this.busId,
    required this.routeFrom,
    required this.routeTo,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.availableSeats,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  bool _isProcessingPayment = false;
  Map<int, bool> _seatAvailability = {};
  List<int> _selectedSeats = [];
  String _paymentMethod = 'orange_money';
  bool _acceptTerms = false;
  String? _errorMessage;
  int _passengerCount = 1;
  bool _needsInsurance = false;
  bool _needsLuggage = false;

  // Informations sur les sièges
  final int _rows = 10;
  final int _seatsPerRow = 5;
  final List<String> _rowLabels = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    _loadSeatAvailability();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadSeatAvailability() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Vérifier si nous avons déjà les données en cache
      final cacheKey =
          '${widget.busId}_${widget.departureTime.toIso8601String()}';

      // Obtenir la disponibilité des sièges
      final seatAvailability = await _apiService.getSeatAvailability(
        widget.busId,
        widget.departureTime,
      );

      setState(() {
        _seatAvailability = seatAvailability;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement des sièges disponibles: $e';
      });
    }
  }

  void _toggleSeatSelection(int seatNumber) {
    if (!_seatAvailability[seatNumber]!) {
      // Siège déjà réservé
      return;
    }

    setState(() {
      if (_selectedSeats.contains(seatNumber)) {
        _selectedSeats.remove(seatNumber);
      } else {
        _selectedSeats.add(seatNumber);
      }
    });
  }

  double get _totalPrice {
    return widget.price * _selectedSeats.length;
  }

  double get _bookingFee {
    return _selectedSeats.length *
        500; // Frais de réservation par siège en FCFA
  }

  double get _insuranceFee {
    return _needsInsurance
        ? _selectedSeats.length * 1000
        : 0; // Assurance en FCFA
  }

  double get _luggageFee {
    return _needsLuggage
        ? _selectedSeats.length * 1500
        : 0; // Frais de bagages en FCFA
  }

  double get _grandTotal {
    return _totalPrice + _bookingFee + _insuranceFee + _luggageFee;
  }

  Future<void> _processPayment() async {
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un siège'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions générales'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _errorMessage = null;
    });

    try {
      // Effectuer la réservation
      final bookingResult = await _apiService.bookTicket(
        busId: widget.busId,
        seats: _selectedSeats,
        passengerName: _nameController.text,
        passengerEmail: _emailController.text,
        passengerPhone: _phoneController.text,
        departureTime: widget.departureTime,
        routeFrom: widget.routeFrom,
        routeTo: widget.routeTo,
      );

      // Naviguer vers l'écran de confirmation
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationScreen(
              bookingId: bookingResult['reference'],
              busId: widget.busId,
              routeFrom: widget.routeFrom,
              routeTo: widget.routeTo,
              departureTime: widget.departureTime,
              arrivalTime: widget.arrivalTime,
              seats: _selectedSeats,
              passengerName: _nameController.text,
              passengerEmail: _emailController.text,
              passengerPhone: _phoneController.text,
              price: widget.price,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du traitement du paiement: $e';
      });
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservation'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSeatAvailability,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTripInfo(),
                      const SizedBox(height: 24),
                      _buildSeatSelection(),
                      const SizedBox(height: 24),
                      _buildContactForm(),
                      const SizedBox(height: 24),
                      _buildAdditionalOptions(),
                      const SizedBox(height: 24),
                      _buildPaymentOptions(),
                      const SizedBox(height: 24),
                      _buildPriceSummary(),
                      const SizedBox(height: 24),
                      _buildTermsAndConditions(),
                      const SizedBox(height: 24),
                      _buildBookButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTripInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails du voyage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Départ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.routeFrom,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.departureTime.day}/${widget.departureTime.month}/${widget.departureTime.year} à ${widget.departureTime.hour.toString().padLeft(2, '0')}:${widget.departureTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: AppTheme.primaryColor,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Arrivée',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.routeTo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.arrivalTime.day}/${widget.arrivalTime.month}/${widget.arrivalTime.year} à ${widget.arrivalTime.hour.toString().padLeft(2, '0')}:${widget.arrivalTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sélection des sièges',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_selectedSeats.length} sélectionné(s)',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSeatLegend(),
            const SizedBox(height: 16),
            _buildBusLayout(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          color: Colors.grey[300]!,
          label: 'Disponible',
        ),
        _buildLegendItem(
          color: AppTheme.primaryColor,
          label: 'Sélectionné',
        ),
        _buildLegendItem(
          color: Colors.grey[700]!,
          label: 'Réservé',
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildBusLayout() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avant du bus
          Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'AVANT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Sièges
          for (int row = 1; row <= _rows; row++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int seat = 0; seat < _seatsPerRow; seat++) ...[
                  if (seat == 2) const SizedBox(width: 24),
                  _buildSeat(row, seat),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildSeat(int row, int seatInRow) {
    final seatNumber = (row - 1) * _seatsPerRow + seatInRow + 1;
    final isAvailable = _seatAvailability[seatNumber] ?? false;
    final isSelected = _selectedSeats.contains(seatNumber);
    final seatLabel = '$row${_rowLabels[seatInRow]}';

    return GestureDetector(
      onTap: isAvailable ? () => _toggleSeatSelection(seatNumber) : null,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : isAvailable
                  ? Colors.grey[300]
                  : Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[400]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            seatLabel,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informations de contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Options supplémentaires',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Assurance voyage'),
              subtitle: const Text('1000 FCFA par passager'),
              value: _needsInsurance,
              onChanged: (value) {
                setState(() {
                  _needsInsurance = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Bagages supplémentaires'),
              subtitle: const Text('1500 FCFA par passager'),
              value: _needsLuggage,
              onChanged: (value) {
                setState(() {
                  _needsLuggage = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Méthode de paiement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              title: 'Orange Money',
              subtitle: 'Paiement via Orange Money',
              value: 'orange_money',
              icon: Icons.account_balance_wallet,
              color: Colors.orange,
            ),
            const Divider(),
            _buildPaymentOption(
              title: 'MTN Mobile Money',
              subtitle: 'Paiement via MTN Mobile Money',
              value: 'mtn_money',
              icon: Icons.account_balance_wallet,
              color: Colors.yellow.shade800,
            ),
            const Divider(),
            _buildPaymentOption(
              title: 'Moov Money',
              subtitle: 'Paiement via Moov Money',
              value: 'moov_money',
              icon: Icons.account_balance_wallet,
              color: Colors.blue,
            ),
            const Divider(),
            _buildPaymentOption(
              title: 'Carte bancaire',
              subtitle: 'Visa, Mastercard, etc.',
              value: 'card',
              icon: Icons.credit_card,
              color: Colors.green,
            ),
            const Divider(),
            _buildPaymentOption(
              title: 'Paiement à la gare',
              subtitle: 'Payez en espèces à la gare avant le départ',
              value: 'cash',
              icon: Icons.money,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      value: value,
      groupValue: _paymentMethod,
      onChanged: (newValue) {
        setState(() {
          _paymentMethod = newValue!;
        });
      },
      secondary: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildPriceSummary() {
    final formatPrice = (double price) => '${price.toStringAsFixed(0)} FCFA';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé du prix',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Prix du billet (${_selectedSeats.length} ${_selectedSeats.length > 1 ? 'sièges' : 'siège'})'),
                Text(formatPrice(_totalPrice)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Frais de réservation'),
                Text(formatPrice(_bookingFee)),
              ],
            ),
            if (_needsInsurance) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Assurance voyage'),
                  Text(formatPrice(_insuranceFee)),
                ],
              ),
            ],
            if (_needsLuggage) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Frais de bagages supplémentaires'),
                  Text(formatPrice(_luggageFee)),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  formatPrice(_grandTotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value!;
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: const Text(
              'J\'accepte les conditions générales de vente et la politique de confidentialité',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.primaryColor,
        ),
        child: _isProcessingPayment
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'CONFIRMER ET PAYER',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
