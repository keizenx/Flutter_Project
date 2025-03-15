import 'package:flutter/material.dart';

class User extends StatelessWidget {
  const User({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          const Text(
            'John Doe', // À remplacer par le nom de l'utilisateur
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Mes commandes'),
            onTap: () {
              // Navigation vers les commandes
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Mes adresses'),
            onTap: () {
              // Navigation vers les adresses
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Moyens de paiement'),
            onTap: () {
              // Navigation vers les moyens de paiement
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              // Navigation vers les paramètres
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Logique de déconnexion
            },
          ),
        ],
      ),
    );
  }
}
