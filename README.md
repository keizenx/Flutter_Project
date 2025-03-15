# IvoireBus - Application de Réservation de Bus

Une application mobile développée avec Flutter pour la réservation de billets de bus en Côte d'Ivoire.

## Fonctionnalités

- Recherche d'itinéraires de bus
- Réservation de billets
- Sélection de sièges
- Paiement mobile
- Gestion des billets électroniques
- Suivi des bus en temps réel
- Historique des voyages
- Profil utilisateur

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

4. Créez un fichier `.env` à la racine du projet avec les variables suivantes :
```
API_BASE_URL=https://api.example.com
API_VERSION=v1
API_KEY=votre_cle_api
API_LANGUAGE=fr
API_CURRENCY=XOF

SMTP_USERNAME=votre_email@gmail.com
SMTP_PASSWORD=votre_mot_de_passe_application
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587

GOOGLE_MAPS_API_KEY=votre_cle_api_google_maps
```

5. Lancez l'application
```bash
flutter run
```

## Captures d'écran

*À venir*

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou à soumettre une pull request.

## Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.
