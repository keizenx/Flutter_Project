import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/bus_results_screen.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions & Offres'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeaturedPromotion(context),
            const SizedBox(height: 24),
            const Text(
              'Offres Actuelles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPromoCard(
              context,
              title: 'Spécial Weekend',
              code: 'WEEKEND20',
              discount: '20%',
              expiry: 'Valable jusqu\'à dimanche',
              color: Colors.blue,
              icon: Icons.weekend,
            ),
            _buildPromoCard(
              context,
              title: 'Réduction Étudiant',
              code: 'ETUDIANT15',
              discount: '15%',
              expiry: 'Valable avec carte étudiant',
              color: Colors.green,
              icon: Icons.school,
            ),
            _buildPromoCard(
              context,
              title: 'Pack Famille',
              code: 'FAMILLE25',
              discount: '25%',
              expiry: 'Pour 4+ passagers',
              color: Colors.purple,
              icon: Icons.family_restroom,
            ),
            const SizedBox(height: 24),
            const Text(
              'Offres Saisonnières',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSeasonalOffers(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedPromotion(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.accentColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
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
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'TEMPS LIMITÉ',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Soldes d\'Été',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '30% de réduction sur tous les trajets',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    _showPromoDetails(
                      context,
                      'Soldes d\'Été',
                      'ETE30',
                      '30%',
                      'Obtenez 30% de réduction sur tous les trajets pendant nos soldes d\'été ! Réservez vos billets maintenant et profitez de grandes économies sur vos voyages.',
                      'Valable jusqu\'au 31 août 2024',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('OBTENIR L\'OFFRE'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(
    BuildContext context, {
    required String title,
    required String code,
    required String discount,
    required String expiry,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showPromoDetails(
            context,
            title,
            code,
            discount,
            'Utilisez ce code lors du paiement pour obtenir $discount de réduction sur votre réservation.',
            expiry,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expiry,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    discount + ' DE RÉDUCTION',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      code,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonalOffers(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSeasonalOfferCard(
            context,
            title: 'Spécial Vacances',
            discount: '25% DE RÉDUCTION',
            image: 'https://via.placeholder.com/150',
            color: Colors.red,
          ),
          _buildSeasonalOfferCard(
            context,
            title: 'Rentrée Scolaire',
            discount: '15% DE RÉDUCTION',
            image: 'https://via.placeholder.com/150',
            color: Colors.orange,
          ),
          _buildSeasonalOfferCard(
            context,
            title: 'Voyage d\'Affaires',
            discount: '10% DE RÉDUCTION',
            image: 'https://via.placeholder.com/150',
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalOfferCard(
    BuildContext context, {
    required String title,
    required String discount,
    required String image,
    required Color color,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Opacity(
                opacity: 0.2,
                child: Container(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  discount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    _showPromoDetails(
                      context,
                      title,
                      title.toUpperCase().replaceAll(' ', '').substring(0, 4) +
                          '25',
                      discount.split(' ')[0],
                      'Profitez de cette offre spéciale pour vos voyages $title. Réservez maintenant pour économiser!',
                      'Offre à durée limitée',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: color,
                    minimumSize: const Size(double.infinity, 36),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('VOIR DÉTAILS'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPromoDetails(
    BuildContext context,
    String title,
    String code,
    String discount,
    String description,
    String expiry,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      discount + ' DE RÉDUCTION',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  expiry,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          code,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Code promo copié dans le presse-papiers'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copier dans le presse-papiers',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Naviguer vers l'écran de résultats de bus avec des destinations populaires
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusResultsScreen(
                          from: 'Abidjan',
                          to: 'Yamoussoukro',
                          date: DateTime.now().add(const Duration(days: 1)),
                          passengers: 1,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('RÉSERVER MAINTENANT'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
