# IvoireBus - Application de Réservation de Bus

Une application mobile développée avec Flutter pour la réservation de billets de bus en Côte d'Ivoire.

## Dernières Mises à Jour

- Correction du modèle de ticket pour utiliser `busType` au lieu de `busNumber`
- Ajout de la structure de dossiers requise pour les assets
- Configuration du fichier .env pour les variables d'environnement

## Fonctionnalités

- Recherche d'itinéraires de bus
- Réservation de billets
- Sélection de sièges
- Paiement mobile
- Gestion des billets électroniques
- Suivi des bus en temps réel
- Historique des voyages
- Profil utilisateur

## Configuration Requise

Avant de lancer l'application, assurez-vous d'avoir :

1. Le dossier `assets/icons/` créé à la racine du projet
2. Un fichier `.env` configuré avec les variables suivantes :
```env
# API Configuration
API_URL=http://localhost:3000
API_KEY=your_api_key_here

# Map Configuration
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here

# Autres configurations (si nécessaire)
SMTP_USERNAME=votre_email@gmail.com
SMTP_PASSWORD=votre_mot_de_passe_application
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
```

## Technologies utilisées

- Flutter
- Dart
- SharedPreferences pour le stockage local
- Intégration SMTP pour l'envoi d'emails
- Google Maps pour le suivi des bus

## Installation

1. Clonez ce dépôt
```bash
git clone https://github.com/keizenx/Flutter_Project.git
```

2. Naviguez dans le répertoire du projet
```bash
cd Flutter_Project
```

3. Installez les dépendances
```bash
flutter pub get
```

4. Créez les dossiers requis
```bash
mkdir -p assets/icons
```

5. Configurez le fichier `.env` comme indiqué dans la section Configuration Requise

6. Lancez l'application
```bash
flutter run
```

## Structure du Projet

```
Flutter_Project/
├── lib/
│   ├── models/
│   │   └── bus_route.dart
│   ├── screens/
│   │   └── ticket_details_screen.dart
│   └── ...
├── assets/
│   └── icons/
├── .env
└── pubspec.yaml
```

## Captures d'écran

*À venir*

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou à soumettre une pull request.

## Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.
