# Tic Tac Toe – Flutter

Un petit jeu de morpion (3×3) développé en **Flutter**, jouable :

- **En ligne (1v1)** via **Firebase / Cloud Firestore** et un lien ou un ID de partage
- **En local (1v1)** sur le même appareil
- **En solo vs IA** (IA simple qui essaie de gagner ou de bloquer)

Ce projet montre comment faire un petit jeu temps réel avec une architecture découpée, du state management moderne (Riverpod) et une UI réutilisable.

---

## ⚠️ Prérequis

- Flutter installé
- **Firebase configuré est obligatoire** : le projet démarre mais les fonctionnalités en ligne dépendent de `firebase_options.dart` généré via `flutterfire configure`.
- Accès à un projet Firebase avec Firestore activé.

---

## 🕹️ Description

- **Écran d’accueil** : écran de sélection du mode de jeu.
- **Mode en ligne** :
  - le joueur A crée une partie → un `gameId` est créé dans Firestore ;
  - il partage l’ID/lien ;
  - le joueur B rejoint avec cet ID ;
  - les deux appareils écoutent le même document Firestore → les coups sont visibles en temps réel.
- **Mode local 1v1** : deux joueurs se passent le téléphone.
- **Mode solo vs IA** : tu joues contre une IA intégrée, qui joue juste après toi.
- **Plateau 3×3** : détection de victoire sur lignes, colonnes et diagonales, plus détection du match nul.
- **Multi-manches** : possibilité de relancer une manche sans recréer toute la partie.

---

## 🏗️ Architecture

L’architecture est organisée de manière **feature-first** pour rester lisible et modulable.

```text
lib/
 ├─ main.dart               # bootstrap Flutter + Firebase
 ├─ app.dart                # MaterialApp, thèmes, i18n, router
 ├─ shared/                 # briques réutilisables (routing, bootstrap…)
 ├─ design_system/          # composants UI communs
 └─ features/
     └─ game/
         ├─ home/           # sélection du mode
         ├─ creation/       # dialogs de création/join
         └─ board/          # logique de partie + écran du plateau
```

### 1. Présentation (UI)

- `GameModeSelectionScreen` : permet de choisir **Online 1v1**, **Local 1v1**, **Solo vs IA**.
- `GameBoardScreen` : affiche la grille, le tour du joueur, l’éventuel gagnant et les actions (nouvelle manche).
- UI basée sur un petit **design system** (cards, spacing, couleurs).

### 2. Application

- Un **notifier/provider** central (via Riverpod) orchestre le déroulement d’une partie :
  - création d’une partie (online ou locale),
  - abonnement aux mises à jour (Firestore ou mémoire),
  - actions de jeu : `makeMove(...)`, `startNewRound(...)`, etc.

### 3. Domaine

- Modèles : `Game`, `Move`, `BoardState`.
- Règles du morpion : détection rapide de victoire ou de match nul.

### 4. Données

- **Implémentation Firestore** :
  - doc principal dans `games/{gameId}`
  - sous-collection des coups
  - synchronisation en temps réel
- **Implémentation locale (in-memory)** :
  - utilisée pour le local et l’IA
  - aucune dépendance réseau

---

## 🛠️ Stack utilisée

- **Flutter** 3.x
- **hooks_riverpod / riverpod_annotation** pour le state management et la DI
- **auto_route** pour la navigation déclarative
- **freezed** + **json_serializable** pour les modèles immuables
- **Firebase Core** + **Cloud Firestore** pour le mode en ligne
- **flutter_localizations** + ARB pour l’i18n
- **google_fonts** pour la typo

---

## 🚀 Démarrage

### 1. Installer les dépendances

```bash
flutter pub get
```

### 2. Générer le code

Le projet utilise plusieurs générateurs (freezed, json, riverpod, auto_route).  
Après modification des modèles ou des providers, lance :

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Lancer l’application

```bash
flutter run
```

---

## 🔥 Configuration Firebase (mode en ligne)

1. Crée un projet Firebase.
2. Configure ton app Flutter avec :

   ```bash
   flutterfire configure
   ```

3. Vérifie que `firebase_options.dart` est bien généré.
4. Le mode en ligne utilisera une collection **`games`** dans Firestore, avec éventuellement une sous-collection pour les coups.

---

## 🎮 Détail des modes

### Online 1v1

- Création de partie → génération d’un ID
- Partage de l’ID
- Jointure par le second joueur
- Les deux sont synchronisés via Firestore

### Local 1v1

- Deux joueurs, un seul téléphone
- Pas de réseau requis
- Alternance automatique des tours

### Solo vs IA

- Même logique que le local
- Après ton coup, l’IA joue :
  1. elle essaie de jouer un coup gagnant ;
  2. sinon elle bloque ton coup gagnant ;
  3. sinon elle joue un coup par défaut.

---

## 🧪 Tests

Pour exécuter les tests :

```bash
flutter test
```

et pour maj les goldens

```bash
flutter test --update-goldens
```

---

## 🧹 Qualité

Pour analyser le code :

```bash
flutter analyze
```

Pour vérifier la couverture:

Pré-requis : brew install lcov

```bash
flutter test --coverage

# puis on enlève les fichiers générés du rapport
lcov --remove coverage/lcov.info \
  '**/*.g.dart' \
  '**/*.freezed.dart' \
  '**/*.gen.dart' \
  '**/*.gr.dart' \
  '**/*.mocks.dart' \
  'lib/generated/**' \
  -o coverage/lcov.info

# puis on génère le HTML
genhtml coverage/lcov.info -o coverage
```

![Coverage](docs/coverage.png)

---

## 🗂️ Scripts utiles

```bash
# regénérer tout le code
dart run build_runner build --delete-conflicting-outputs

# analyser
flutter analyze

# lancer les tests
flutter test

# mettre à jour les goldens
flutter test --update-goldens
```
