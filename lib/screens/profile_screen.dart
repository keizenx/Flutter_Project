import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/email_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Français';
  String? _profileImagePath;
  List<Map<String, dynamic>> _favoriteRoutes = [];
  List<Map<String, dynamic>> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final databaseService =
        Provider.of<DatabaseService>(context, listen: false);

    if (authService.currentUser != null) {
      final userId = authService.currentUser!['id'] as String;

      // Charger les itinéraires favoris
      final favoriteRoutes =
          await databaseService.getFavoriteRoutesByUserId(userId);

      // Charger les moyens de paiement
      final paymentMethods =
          await databaseService.getPaymentMethodsByUserId(userId);

      setState(() {
        _favoriteRoutes = favoriteRoutes;
        _paymentMethods = paymentMethods;
        _profileImagePath =
            authService.currentUser!['profile_image'] as String?;
      });
    }
  }

  void _uploadProfileImage() {
    // Simuler la sélection d'une image
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une photo de profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                // Simuler la prise de photo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité de caméra simulée'),
                    duration: Duration(seconds: 2),
                  ),
                );
                _updateProfileImage('assets/images/bus_background.jpg');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                // Simuler la sélection depuis la galerie
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité de galerie simulée'),
                    duration: Duration(seconds: 2),
                  ),
                );
                _updateProfileImage('assets/images/bus_background.jpg');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfileImage(String imagePath) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.currentUser != null) {
      final userId = authService.currentUser!['id'] as String;

      final result = await authService.updateProfile(
        userId: userId,
        userData: {'profile_image': imagePath},
      );

      if (result['success']) {
        setState(() {
          _profileImagePath = imagePath;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      // Si l'utilisateur n'est pas connecté, rediriger vers l'écran de connexion
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final userName = currentUser['name'] as String;
    final userEmail = currentUser['email'] as String;
    final userPhone = currentUser['phone'] as String;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(userName),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.orange,
                      Colors.green,
                    ],
                  ),
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: _uploadProfileImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImagePath != null
                              ? AssetImage(_profileImagePath!)
                              : null,
                          child: _profileImagePath == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'Informations du compte',
                    children: [
                      _buildListTile(
                        icon: Icons.email,
                        title: 'Email',
                        subtitle: userEmail,
                        onTap: () => _showEditDialog('Email', userEmail),
                      ),
                      _buildListTile(
                        icon: Icons.phone,
                        title: 'Téléphone',
                        subtitle: userPhone,
                        onTap: () =>
                            _showEditDialog('Numéro de téléphone', userPhone),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Emails en attente'),
                        subtitle:
                            const Text('Voir et gérer les emails non envoyés'),
                        onTap: () {
                          _showPendingEmailsDialog(context);
                        },
                      ),
                    ],
                  ),
                  _buildSection(
                    title: 'Préférences de voyage',
                    children: [
                      _buildListTile(
                        icon: Icons.favorite,
                        title: 'Itinéraires favoris',
                        onTap: () => _showFavoriteRoutes(),
                      ),
                      _buildListTile(
                        icon: Icons.history,
                        title: 'Historique de voyage',
                        onTap: () => Navigator.pushNamed(context, '/history'),
                      ),
                      _buildListTile(
                        icon: Icons.location_on,
                        title: 'Suivi des bus',
                        onTap: () =>
                            Navigator.pushNamed(context, '/bus_tracking'),
                      ),
                    ],
                  ),
                  _buildSection(
                    title: 'Moyens de paiement',
                    children: _paymentMethods.isEmpty
                        ? [
                            _buildListTile(
                              icon: Icons.add_circle_outline,
                              title: 'Ajouter un moyen de paiement',
                              onTap: () => _showAddPaymentMethod(),
                            ),
                          ]
                        : [
                            ..._paymentMethods.map((method) {
                              final isCard = method['method_type'] == 'card';
                              final isMobileMoney =
                                  method['method_type'] == 'mobile_money';

                              return _buildListTile(
                                icon: isCard
                                    ? Icons.credit_card
                                    : Icons.account_balance_wallet,
                                title: isCard
                                    ? '**** **** **** ${method['card_number'].toString().substring(method['card_number'].toString().length - 4)}'
                                    : isMobileMoney
                                        ? method['mobile_money_number']
                                        : 'Moyen de paiement',
                                subtitle: isCard
                                    ? 'Expire ${method['expiry_date']}'
                                    : isMobileMoney
                                        ? (method['method_type'] ==
                                                'orange_money'
                                            ? 'Orange Money'
                                            : 'MTN Mobile Money')
                                        : '',
                                trailing: method['is_default'] == 1
                                    ? const Icon(Icons.check_circle,
                                        color: AppTheme.accentColor)
                                    : null,
                                onTap: () => _showPaymentDetails(method),
                              );
                            }).toList(),
                            _buildListTile(
                              icon: Icons.add_circle_outline,
                              title: 'Ajouter un moyen de paiement',
                              onTap: () => _showAddPaymentMethod(),
                            ),
                          ],
                  ),
                  _buildSection(
                    title: 'Paramètres',
                    children: [
                      _buildListTile(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value
                                      ? 'Notifications activées'
                                      : 'Notifications désactivées',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                      ),
                      _buildListTile(
                        icon: Icons.language,
                        title: 'Langue',
                        subtitle: _selectedLanguage,
                        onTap: () => _showLanguageSelector(),
                      ),
                      _buildListTile(
                        icon: Icons.dark_mode,
                        title: 'Mode sombre',
                        trailing: Switch(
                          value: _isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              _isDarkMode = value;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value
                                      ? 'Mode sombre activé'
                                      : 'Mode sombre désactivé',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  _buildSection(
                    title: 'Support',
                    children: [
                      _buildListTile(
                        icon: Icons.help_outline,
                        title: 'Centre d\'aide',
                        onTap: () => _showHelpCenter(),
                      ),
                      _buildListTile(
                        icon: Icons.info_outline,
                        title: 'À propos',
                        onTap: () => _showAboutDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showLogoutConfirmation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Déconnexion'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  Future<void> _showEditDialog(String field, String currentValue) async {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.currentUser == null) return;

    final userId = authService.currentUser!['id'] as String;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              Map<String, dynamic> updateData = {
                'userId': userId,
              };

              if (field == 'Email') {
                updateData['email'] = controller.text.trim();
              } else if (field == 'Numéro de téléphone') {
                updateData['phone'] = controller.text.trim();
              } else if (field == 'Nom complet') {
                updateData['name'] = controller.text.trim();
              }

              final result = await authService.updateProfile(
                userId: userId,
                userData: updateData,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['success']
                      ? '$field mis à jour'
                      : result['message']),
                  backgroundColor:
                      result['success'] ? Colors.green : Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );

              if (result['success']) {
                setState(() {});
              }
            },
            child: const Text('ENREGISTRER'),
          ),
        ],
      ),
    );
  }

  void _showFavoriteRoutes() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Itinéraires favoris',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _favoriteRoutes.isEmpty
                ? const Center(
                    child: Text('Aucun itinéraire favori'),
                  )
                : Column(
                    children: _favoriteRoutes.map((route) {
                      return _buildFavoriteRouteItem(
                        route['route_from'],
                        route['route_to'],
                        '5000 FCFA',
                        route['id'],
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteRouteItem(
      String from, String to, String price, String id) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.directions_bus, color: AppTheme.primaryColor),
        title: Text('$from → $to'),
        subtitle: const Text('Appuyez pour rechercher'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _deleteFavoriteRoute(id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.pop(context);
          // Naviguer vers la recherche avec ces paramètres
        },
      ),
    );
  }

  Future<void> _deleteFavoriteRoute(String id) async {
    final databaseService =
        Provider.of<DatabaseService>(context, listen: false);

    await databaseService.deleteFavoriteRoute(id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Itinéraire supprimé des favoris'),
        duration: Duration(seconds: 2),
      ),
    );

    _loadUserData();
  }

  void _showPaymentDetails(Map<String, dynamic> method) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails du moyen de paiement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                method['method_type'] == 'card'
                    ? Icons.credit_card
                    : Icons.account_balance_wallet,
                color: AppTheme.primaryColor,
              ),
              title: Text(
                method['method_type'] == 'card'
                    ? '**** **** **** ${method['card_number'].toString().substring(method['card_number'].toString().length - 4)}'
                    : method['mobile_money_number'] ?? '',
              ),
              subtitle: Text(
                method['method_type'] == 'card'
                    ? 'Expire ${method['expiry_date']}'
                    : method['method_type'] == 'orange_money'
                        ? 'Orange Money'
                        : 'MTN Mobile Money',
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                // Afficher le formulaire d'édition
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _deletePaymentMethod(method['id']);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePaymentMethod(String id) async {
    final databaseService =
        Provider.of<DatabaseService>(context, listen: false);

    await databaseService.deletePaymentMethod(id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Moyen de paiement supprimé'),
        duration: Duration(seconds: 2),
      ),
    );

    _loadUserData();
  }

  void _showAddPaymentMethod() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final databaseService =
        Provider.of<DatabaseService>(context, listen: false);

    if (authService.currentUser == null) return;

    final userId = authService.currentUser!['id'] as String;

    final TextEditingController cardNumberController = TextEditingController();
    final TextEditingController expiryDateController = TextEditingController();
    final TextEditingController cvvController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un moyen de paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Numéro de carte',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date d\'expiration',
                      hintText: 'MM/AA',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nom du titulaire',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Simuler l'ajout d'une carte
              await databaseService.insertPaymentMethod({
                'user_id': userId,
                'method_type': 'card',
                'card_number': '4242424242424242',
                'expiry_date': '12/25',
                'is_default': _paymentMethods.isEmpty ? 1 : 0,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Moyen de paiement ajouté'),
                  duration: Duration(seconds: 2),
                ),
              );

              _loadUserData();
            },
            child: const Text('AJOUTER'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    final languages = ['Français', 'English', 'Español', 'Deutsch', 'Italiano'];

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Sélectionner la langue'),
        children: languages
            .map((language) => SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedLanguage = language;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Langue changée en $language'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        _selectedLanguage == language
                            ? const Icon(Icons.check_circle,
                                color: AppTheme.primaryColor)
                            : const Icon(Icons.circle_outlined,
                                color: Colors.grey),
                        const SizedBox(width: 16),
                        Text(language),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _showHelpCenter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Centre d\'aide',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHelpItem('Comment réserver un billet?'),
            _buildHelpItem('Politique d\'annulation'),
            _buildHelpItem('Problèmes de paiement'),
            _buildHelpItem('Contacter le support'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat avec le support initié'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.chat),
              label: const Text('Discuter avec le support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String title) {
    return ListTile(
      leading: const Icon(Icons.help_outline, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        // Afficher l'article d'aide
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ouverture de l\'article d\'aide: $title'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'IvoireBus',
        applicationVersion: '1.0.0',
        applicationIcon: const FlutterLogo(size: 48),
        applicationLegalese: '© 2024 IvoireBus',
        children: [
          const SizedBox(height: 16),
          const Text(
            'Une application moderne de réservation de bus qui permet aux utilisateurs de rechercher, réserver et suivre les bus en Côte d\'Ivoire.',
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.logout();

              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DÉCONNEXION'),
          ),
        ],
      ),
    );
  }

  void _showPendingEmailsDialog(BuildContext context) async {
    final emailService = EmailService();
    final prefs = await SharedPreferences.getInstance();
    final pendingEmails = prefs.getStringList('pending_emails') ?? [];

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Emails en attente'),
          content: SizedBox(
            width: double.maxFinite,
            child: pendingEmails.isEmpty
                ? const Text('Aucun email en attente')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: pendingEmails.length,
                    itemBuilder: (context, index) {
                      final emailData = json.decode(pendingEmails[index])
                          as Map<String, dynamic>;
                      return ListTile(
                        title: Text(emailData['subject'] as String),
                        subtitle: Text('À: ${emailData['to']}'),
                        trailing: Text(
                          DateTime.parse(emailData['timestamp'] as String)
                              .toLocal()
                              .toString()
                              .substring(0, 16),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fermer'),
            ),
            if (pendingEmails.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  // Afficher un indicateur de chargement
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return const AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Tentative d\'envoi des emails en attente...'),
                          ],
                        ),
                      );
                    },
                  );

                  // Tenter d'envoyer les emails en attente
                  final result = await emailService.sendPendingEmails();

                  if (!mounted) return;

                  // Fermer l'indicateur de chargement
                  Navigator.pop(context);

                  // Afficher le résultat
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Emails envoyés: ${result['sent']}, Échecs: ${result['failed']}, Restants: ${result['remaining']}',
                      ),
                      backgroundColor:
                          result['sent'] > 0 ? Colors.green : Colors.orange,
                    ),
                  );
                },
                child: const Text('Tenter l\'envoi'),
              ),
          ],
        );
      },
    );
  }
}
