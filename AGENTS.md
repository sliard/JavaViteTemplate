# Agents GitHub Copilot

Ce document décrit les agents et skills disponibles pour ce projet fullstack Java/Spring Boot + React/Vite.

## 🤖 Vue d'ensemble

Ce template utilise les **Agents** et **Skills**, des standards ouverts supportés par GitHub Copilot. Les agents effectuent des tâches autonomes complexes, tandis que les skills enseignent à Copilot des tâches spécifiques répétables.

---

## 🧠 Agents Disponibles

### `Architecte Backend`

**Chemin** : `.github/agents/backend-architect.md`

**But** : Vérifier la cohérence et la qualité architecturale du backend Spring Boot.

**Déclenchement** : Demandes d'audit, revue d'architecture, vérification des conventions, analyse de la structure du projet backend.

**Responsabilités** :

#### 1. Cohérence Spring Boot
- Vérifier la compatibilité des versions (Spring Boot 3.4.x, Java 21)
- Valider la configuration des starters et dépendances
- Contrôler les fichiers `application.yml` / `application.properties`
- Vérifier les profils Spring (dev, prod, test)

#### 2. Architecture MVC / Clean Architecture
- Valider la séparation des couches (Controller → Service → Repository → Entity)
- Vérifier l'absence de logique métier dans les controllers
- Contrôler que les entités ne sont pas exposées directement (utilisation de DTOs)
- Valider le pattern Interface + Implémentation pour les services
- Vérifier l'injection de dépendances par constructeur

#### 3. Conventions REST
- Valider le nommage des endpoints (`/api/` prefix, ressources au pluriel)
- Vérifier les codes HTTP appropriés (200, 201, 204, 400, 401, 403, 404, 500)
- Contrôler la pagination sur les endpoints de liste
- Valider la documentation OpenAPI/Swagger
- Vérifier la cohérence des DTOs (Request/Response)

#### 4. Gestion Configuration & Sécurité
- Auditer la configuration Spring Security
- Vérifier la configuration JWT (secrets, expiration, refresh tokens)
- Contrôler les endpoints publics vs protégés
- Valider la configuration CORS
- Vérifier l'absence de secrets hardcodés
- Contrôler les variables d'environnement

#### 5. Gestion des Tests
- Vérifier la présence de tests unitaires pour les services
- Contrôler les tests d'intégration pour les controllers
- Valider la configuration des tests (@SpringBootTest, @WebMvcTest, @DataJpaTest)
- Vérifier l'utilisation de Testcontainers pour les tests de repository
- Contrôler la couverture de code

**Checklist d'audit** :

```
□ Structure des packages conforme (controller/, service/, repository/, entity/, dto/, config/, security/)
□ Entités avec UUID et timestamps (createdAt, updatedAt)
□ DTOs séparés (Request/Response) avec validation Bean Validation
□ Services avec @Transactional approprié
□ Controllers avec documentation OpenAPI
□ GlobalExceptionHandler configuré
□ Spring Security avec JWT configuré
□ Tests unitaires présents (>80% couverture services)
□ Tests d'intégration pour les endpoints critiques
□ Configuration externalisée (pas de secrets hardcodés)
```

**Exemples de prompts** :
- "Audite l'architecture backend du projet"
- "Vérifie les conventions REST de mes controllers"
- "Analyse la configuration de sécurité Spring"
- "Revue la structure des tests backend"
- "Vérifie la cohérence des couches du projet"

**Outils utilisés** :
- Analyse statique du code source
- Vérification des dépendances Maven/Gradle
- Inspection des fichiers de configuration
- Analyse de la couverture de tests

---

### `Architecte Frontend`

**Chemin** : `.github/agents/frontend-architect.md`

**But** : Vérifier la cohérence et la qualité architecturale du frontend React/TypeScript/Vite.

**Déclenchement** : Demandes d'audit, revue d'architecture, vérification des conventions composants, analyse de la performance, validation des tests frontend.

**Responsabilités** :

#### 1. Cohérence React/TypeScript/Vite
- Vérifier la compatibilité des versions (React 19, Vite 6.x, TypeScript 5.x, Node 22)
- Valider la configuration TypeScript (mode strict activé)
- Contrôler la configuration Vite (proxy, plugins)
- Vérifier les variables d'environnement (préfixe `VITE_`)

#### 2. Architecture Fonctionnelle
- Valider la structure des dossiers (components, hooks, pages, services, store, types)
- Vérifier les règles de dépendances entre couches
- Contrôler la séparation des responsabilités
- Détecter les anti-patterns (logique métier dans les composants)

#### 3. Conventions Composants
- Valider le nommage PascalCase des composants
- Vérifier les exports nommés (pas de default export)
- Contrôler le typage des props avec interfaces
- Valider l'utilisation exclusive de functional components

#### 4. Conventions Hooks
- Vérifier le préfixe `use` obligatoire
- Contrôler les interfaces Options/Result
- Valider la gestion des états (loading, error, data)
- Vérifier les dépendances useEffect/useCallback/useMemo

#### 5. Services API
- Valider l'utilisation des variables d'environnement
- Vérifier la gestion centralisée des headers et erreurs
- Contrôler le typage strict des requêtes/réponses
- Valider les méthodes CRUD cohérentes

#### 6. Types TypeScript
- Vérifier l'organisation par domaine
- Contrôler les suffixes cohérents (Request, Response, Props)
- Valider l'utilisation de `interface` vs `type`
- Vérifier les propriétés optionnelles

#### 7. Authentification
- Auditer l'AuthContext et Provider
- Vérifier le hook useAuth avec validation de contexte
- Contrôler les routes protégées et redirections
- Valider la gestion des tokens (stockage, refresh)

#### 8. Performance
- Vérifier l'utilisation de React.memo, useMemo, useCallback
- Contrôler le lazy loading des pages
- Valider le code splitting
- Analyser la taille du bundle

#### 9. Accessibilité
- Vérifier les rôles ARIA appropriés
- Contrôler les labels sur les inputs
- Valider la navigation au clavier
- Vérifier le contraste des couleurs

#### 10. Tests Frontend
- Vérifier la présence de tests pour les composants
- Contrôler les tests de hooks
- Valider la configuration Vitest + Testing Library
- Vérifier la couverture de code (>75%)

**Checklist d'audit** :

```
□ Structure des dossiers conforme (components/, hooks/, pages/, services/, types/)
□ TypeScript en mode strict activé
□ Composants avec props typées et exports nommés
□ Hooks avec gestion loading/error/data
□ Services API avec gestion centralisée des erreurs
□ Types organisés par domaine avec suffixes cohérents
□ AuthContext configuré avec routes protégées
□ Lazy loading des pages implémenté
□ Accessibilité respectée (ARIA, labels, clavier)
□ Tests présents (>75% couverture)
```

**Exemples de prompts** :
- "Audite l'architecture frontend du projet"
- "Vérifie la structure des composants React"
- "Analyse les conventions des hooks personnalisés"
- "Revue la configuration TypeScript"
- "Vérifie la performance et l'accessibilité"
- "Analyse la couverture des tests frontend"

**Outils utilisés** :
- Analyse statique TypeScript/ESLint
- Vérification des dépendances npm
- Inspection des fichiers de configuration (tsconfig, vite.config)
- Analyse de la couverture de tests Vitest
- Audit Lighthouse (performance, accessibilité)

---

## 📦 Skills Disponibles

Ce template utilise les **Agent Skills**, un standard ouvert supporté par GitHub Copilot. Les skills permettent d'enseigner à Copilot comment effectuer des tâches spécifiques de manière répétable.

### Comment fonctionnent les skills

1. Chaque skill est un dossier dans `.github/skills/`
2. Chaque dossier contient un fichier `SKILL.md` avec un frontmatter YAML
3. Copilot charge automatiquement le skill approprié selon la description et le contexte de votre prompt

### Format d'un skill

```markdown
---
name: skill-name
description: Description du skill et quand Copilot doit l'utiliser.
---

# Instructions détaillées

Contenu Markdown avec les instructions, exemples et guidelines.
```

---

## 📦 Skills Backend (Spring Boot)

### `backend-entity`

**Chemin** : `.github/skills/backend-entity/SKILL.md`

**Déclenchement** : Demandes de création d'entités JPA, modèles de données, objets de domaine.

**Fonctionnalités** :
- Entités avec UUID et timestamps automatiques
- Annotations Lombok (`@Data`, `@Builder`)
- Relations JPA (OneToMany, ManyToOne, ManyToMany)
- Configuration de l'auditing

**Exemples de prompts** :
- "Crée une entité Product avec name, price et description"
- "Génère une entité User avec authentification Spring Security"
- "Crée une entité Order avec relation vers User et liste de OrderItems"

---

### `backend-security`

**Chemin** : `.github/skills/backend-security/SKILL.md`

**Déclenchement** : Configuration de l'authentification JWT, Spring Security, endpoints login/register.

**Fonctionnalités** :
- Configuration Spring Security 6.x
- JWT avec access token et refresh token
- Endpoints d'authentification
- CORS configuration
- DTOs d'authentification

**Exemples de prompts** :
- "Configure Spring Security avec JWT"
- "Crée les endpoints login et register"
- "Ajoute un système d'authentification avec refresh token"

---

### `backend-service`

**Chemin** : `.github/skills/backend-service/SKILL.md`

**Déclenchement** : Création de services métier, repositories, logique applicative.

**Fonctionnalités** :
- Pattern Interface + Implémentation
- Repositories Spring Data JPA
- Gestion des transactions
- DTOs avec Java Records
- Gestion des exceptions

**Exemples de prompts** :
- "Crée un service ProductService avec CRUD complet"
- "Génère un repository pour Product avec recherche par catégorie"
- "Ajoute la logique métier pour gérer les commandes"

---

### `backend-controller`

**Chemin** : `.github/skills/backend-controller/SKILL.md`

**Déclenchement** : Création d'endpoints REST, controllers, API HTTP.

**Fonctionnalités** :
- Controllers REST avec pagination
- Documentation OpenAPI/Swagger
- Gestion globale des erreurs
- Sécurité avec `@PreAuthorize`
- Accès à l'utilisateur connecté

**Exemples de prompts** :
- "Crée un controller REST pour Product"
- "Génère les endpoints CRUD pour User avec pagination"
- "Ajoute un endpoint pour publier un produit"

---

## 🎨 Skills Frontend (React/Vite)

### `frontend-component`

**Chemin** : `.github/skills/frontend-component/SKILL.md`

**Déclenchement** : Création de composants React, boutons, cartes, formulaires, modals.

**Fonctionnalités** :
- Composants fonctionnels TypeScript
- Props typées avec interfaces
- Gestion des états (loading, error, empty)
- Accessibilité

**Exemples de prompts** :
- "Crée un composant ProductCard avec image et prix"
- "Génère un formulaire de création de produit"
- "Crée un composant Modal réutilisable"

---

### `frontend-auth`

**Chemin** : `.github/skills/frontend-auth/SKILL.md`

**Déclenchement** : Système d'authentification React, login, logout, routes protégées.

**Fonctionnalités** :
- Context d'authentification
- Hook `useAuth`
- Composant `ProtectedRoute`
- Service d'authentification
- Gestion des tokens JWT

**Exemples de prompts** :
- "Configure l'authentification avec contexte React"
- "Crée un formulaire de login"
- "Ajoute des routes protégées pour l'admin"

---

### `frontend-hooks`

**Chemin** : `.github/skills/frontend-hooks/SKILL.md`

**Déclenchement** : Création de hooks personnalisés, logique réutilisable.

**Fonctionnalités** :
- Hooks de data fetching avec cache
- Hooks de mutation (create/update/delete)
- Hooks utilitaires (debounce, localStorage, mediaQuery)
- Gestion loading/error

**Exemples de prompts** :
- "Crée un hook useProducts pour charger les produits"
- "Génère un hook useDebounce"
- "Crée un hook useLocalStorage typé"

---

### `frontend-services`

**Chemin** : `.github/skills/frontend-services/SKILL.md`

**Déclenchement** : Services API, clients HTTP, communication backend.

**Fonctionnalités** :
- Client API avec gestion des erreurs
- Services par entité (productService, userService)
- Types pour requêtes/réponses
- Upload de fichiers

**Exemples de prompts** :
- "Crée un service API pour les produits"
- "Génère le client HTTP avec gestion du token JWT"
- "Ajoute un service d'upload de fichiers"

---

## 📋 Bonnes pratiques pour les prompts

### Structure recommandée

```
[Action] [Objet] avec [caractéristiques] pour [contexte]
```

### Exemples efficaces

✅ **Bon** : "Crée une entité Order avec id, status (enum PENDING/CONFIRMED/SHIPPED), totalAmount et relation ManyToOne vers User"

✅ **Bon** : "Génère un composant ProductList qui affiche une grille de ProductCard avec pagination et état de chargement"

❌ **Éviter** : "Crée un produit" (trop vague)

### Conseils

1. **Soyez spécifique** : Mentionnez les champs, types, relations
2. **Donnez le contexte** : Admin, public, API interne
3. **Référencez les entités existantes** : "avec relation vers Product existant"
4. **Précisez les contraintes** : "avec validation email unique"

---

## 🔧 Ajouter un nouveau skill

1. Créer un dossier dans `.github/skills/` avec un nom en kebab-case
2. Créer un fichier `SKILL.md` avec le frontmatter requis
3. Optionnellement, ajouter des scripts ou exemples dans le dossier

```
.github/skills/
└── mon-nouveau-skill/
    ├── SKILL.md          # Instructions (requis)
    ├── example.ts        # Exemple de code (optionnel)
    └── template.java     # Template (optionnel)
```

### Frontmatter requis

```yaml
---
name: mon-nouveau-skill          # Identifiant unique (kebab-case)
description: Description claire de ce que fait le skill et quand l'utiliser.
---
```

