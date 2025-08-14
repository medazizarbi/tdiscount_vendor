# TDiscount Vendor

Une application Flutter destinée aux vendeurs pour gérer leurs magasins, produits et commandes.

## Description

TDiscount Vendor est une application mobile conçue spécifiquement pour les vendeurs partenaires de la plateforme TDiscount. Cette application permet aux vendeurs de gérer efficacement leur activité commerciale depuis leur appareil mobile.

## Fonctionnalités

### Gestion du Magasin
- **Tableau de bord** : Vue d'ensemble des performances du magasin
- **Paramètres du magasin** : Configuration des informations de base
- **Statistiques** : Analyse des ventes et performances

### Gestion des Produits
- **Catalogue produits** : Visualisation de tous les produits
- **Ajout de produits** : Création de nouveaux produits
- **Modification** : Mise à jour des informations produits
- **Gestion du stock** : Suivi des niveaux d'inventaire
- **Statut des produits** : Activation/désactivation des produits

### Gestion des Commandes
- **Liste des commandes** : Suivi de toutes les commandes
- **Traitement** : Gestion du statut des commandes
- **Historique** : Consultation des commandes passées

### Fonctionnalités Supplémentaires
- **Mode sombre/clair** : Interface adaptative
- **Interface responsive** : Optimisée pour différentes tailles d'écran
- **Navigation intuitive** : Expérience utilisateur fluide

## Architecture

L'application suit une architecture MVVM (Model-View-ViewModel) moderne avec :
- **Model** : Modèles de données et entités métier
- **View** : Interfaces utilisateur (Widgets Flutter)
- **ViewModel** : Logique métier et gestion d'état
- **Services** : Couche d'accès aux données et appels API
- **Provider** : Gestion d'état réactive
- **Widgets personnalisés** : Interface cohérente
- **Thème adaptatif** : Support du mode sombre

## Technologies Utilisées

- **Flutter** : Framework de développement
- **Dart** : Langage de programmation
- **Provider** : Gestion d'état
- **HTTPS** : Appels API
- **Material Design** : Design system

## Structure du Projet

```
lib/
├── models/          # Modèles de données et entités
├── views/           # Interfaces utilisateur (UI)
├── viewModels/      # Logique métier et gestion d'état
├── services/        # Services API et accès aux données
├── utils/
│   ├── constants/   # Constantes (couleurs, themes)
│   └── widgets/     # Widgets réutilisables
└── main.dart        # Point d'entrée
```

## Installation

1. Clonez le repository
```bash
git clone [repository-url]
```

2. Naviguez vers le dossier du projet
```bash
cd tdiscount_vendor
```

3. Installez les dépendances
```bash
flutter pub get
```

4. Lancez l'application
```bash
flutter run
```

## Configuration Requise

- Flutter SDK: 3.0+
- Dart SDK: 3.0+
- Android Studio / VS Code
- Émulateur Android/iOS ou appareil physique

## Développement

### Ajout de nouvelles fonctionnalités
1. Créez les modèles nécessaires dans `models/`
2. Implémentez les services API dans `services/`
3. Développez la logique métier dans `viewModels/`
4. Créez l'interface dans `views/`
5. Ajoutez les widgets réutilisables dans `utils/widgets/`

### Guidelines de développement
- Utilisez le pattern MVVM avec Services
- Séparez les appels API dans la couche Services
- Respectez la structure des dossiers
- Implémentez le support du mode sombre
- Suivez les conventions de nommage Dart
- Gérez les erreurs dans les ViewModels
- Utilisez Provider pour la gestion d'état

### Structure MVVM
- **Models** : Définissent la structure des données
- **Services** : Gèrent les appels API et la persistance
- **ViewModels** : Contiennent la logique métier et l'état
- **Views** : Affichent l'interface utilisateur

## Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## License

Ce projet est sous licence [MIT License](LICENSE).

## Contact

Pour toute question ou suggestion, contactez l'équipe de développement.

---

**TDiscount Vendor** - Gérez votre business, n'importe où, n'importe quand.
