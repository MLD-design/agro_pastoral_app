📱 Application de gestion agro-pastorale

Application mobile développée avec Flutter permettant de gérer et suivre les activités d’une exploitation agro-pastorale, regroupant les activités agricoles et d’élevage au sein d’une même plateforme.

🎯 Objectif du projet

Les exploitations agro-pastorales utilisent souvent plusieurs outils ou documents pour suivre leurs activités.

Cette application a pour objectif de centraliser ces informations dans une application mobile afin de faciliter :

* le suiviavtivites agro (des cultures,des parcelles,des campagnes agricole)  ;
* la gestion des stocks ;
* le suivi financier ;
* la gestion du personnel ;
* la gestion des alertes ;
* la consultation des données selon le rôle de l’utilisateur.

🚀 Fonctionnalités principales

🌱 Gestion agricole

* Gestion des exploitations
* Gestion des parcelles
* Gestion des cultures
* Suivi des campagnes
* Planification des activités
* Suivi des traitements
* Suivi des récoltes



📦 Gestion des stocks

* Gestion des produits et matériels
* Suivi des entrées et sorties
* Consultation des stocks

💰 Gestion financière

* Suivi des opérations financières
* Consultation des informations financières de l’exploitation

👥 Gestion des utilisateurs

L’application prévoit une gestion des accès basée sur les rôles.

Exemples de rôles :

* Administrateur
* Gestionnaire d’exploitation
* Gestionnaire de stock
* Technicien d’élevage
* Technicien agricole
* Vétérinaire
* Ingénieur agronome

Chaque utilisateur peut accéder aux fonctionnalités correspondant à ses permissions.

🏗️ Architecture

L’application est organisée en plusieurs couches afin de séparer les responsabilités.

Flutter Application
│
├── Pages / UI
│
├── Providers
│
├── Services
│
├── Models
│
└── API REST
       │
       ▼
   Backend Node.js

L’application utilise notamment une séparation entre :

* l’interface utilisateur ;
* la gestion de l’état ;
* les services ;
* les modèles ;
* les appels vers l’API REST.

🛠️ Technologies utilisées

Technologie	Utilisation
Flutter	Développement de l’application mobile
Dart	Langage de programmation
Provider	Gestion d’état
Dio	Communication avec l’API
REST API	Communication avec le backend
JSON	Échange de données
Git	Gestion de versions
GitHub	Hébergement du code

🔗 Backend

Le backend de l’application est développé séparément avec Node.js / Express.js et communique avec l’application Flutter via une API REST.

 



⚙️ Installation

Prérequis

Avant de lancer le projet, installer :

* Flutter
* Dart
* Android Studio ou VS Code
* Git

Vérifier l’installation de Flutter :

flutter doctor

Cloner le projet

git clone <URL_DU_DEPOT_FLUTTER>

Installer les dépendances

flutter pub get

Configurer l’API

Configurer l’URL du backend dans la configuration de l’application.

Exemple :

API_BASE_URL=http://adresse-du-backend

Ne jamais publier de clés API, mots de passe ou informations sensibles dans le dépôt.

Lancer l’application

flutter run

🔐 Authentification et autorisations

L’application intègre un système d’authentification permettant d’identifier l’utilisateur et d’adapter l’accès aux fonctionnalités selon son rôle.

Le principe général est :

Utilisateur
    │
    ▼
Authentification
    │
    ▼
Identification du rôle
    │
    ▼
Autorisation
    │
    ▼
Accès aux fonctionnalités

🔮 Améliorations prévues

* Amélioration de l’interface utilisateur
* Ajout de notifications avancées
* Amélioration du système de rapports
* Ajout de statistiques et graphiques
* Amélioration de la gestion hors connexion
* Tests automatisés
* Déploiement de l’application
* Amélioration de la sécurité

👨‍💻 Auteur

Møuhamedou Lamine Diouf

Étudiant en Master 1 – Génie Logiciel & Data Science
Université Alioune Diop de Bambey

GitHub : MLD-design
