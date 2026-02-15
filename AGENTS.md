# Agents GitHub Copilot

Ce document décrit les agents et skills disponibles pour ce projet fullstack Java/Spring Boot + React/Vite.

## 🤖 Vue d'ensemble

Ce template utilise les **Agents** et **Skills**, des standards ouverts supportés par GitHub Copilot. Les agents effectuent des tâches autonomes complexes, tandis que les skills enseignent à Copilot des tâches spécifiques répétables.

### Résumé

| Type | Nom | Description |
|------|-----|-------------|
| 🤖 Agent | Backend Architect | Audit architecture Spring Boot |
| 🤖 Agent | Frontend Architect | Audit architecture React/TypeScript |
| 🤖 Agent | DevOps | Audit Docker, Nginx, CI/CD |
| 🤖 Agent | Quality | Audit tests et qualité du code |
| 🤖 Agent | API Designer | Conception et audit des APIs REST |
| 📦 Skill | backend-entity | Génération d'entités JPA |
| 📦 Skill | backend-service | Génération services et repositories |
| 📦 Skill | backend-controller | Génération controllers REST |
| 📦 Skill | backend-security | Configuration Spring Security + JWT |
| 📦 Skill | backend-testing | Tests JUnit 5, Mockito, Testcontainers |
| 📦 Skill | backend-migration | Migrations Flyway SQL |
| 📦 Skill | backend-exception | Gestion des exceptions |
| 📦 Skill | backend-dto-mapper | Mappers DTO avec MapStruct |
| 📦 Skill | frontend-component | Composants React TypeScript |
| 📦 Skill | frontend-hooks | Hooks personnalisés |
| 📦 Skill | frontend-services | Services API |
| 📦 Skill | frontend-auth | Authentification React |
| 📦 Skill | frontend-testing | Tests Vitest + Testing Library |
| 📦 Skill | frontend-form | Formulaires react-hook-form + zod |
| 📦 Skill | frontend-routing | Configuration React Router |
| 📦 Skill | frontend-state | State management avec Zustand |
| 📦 Skill | docker-compose | Configuration Docker Compose |
| 📦 Skill | feature-spec | Spécifications de features |
| 📦 Skill | github-actions | Workflows CI/CD |

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

## 🆕 Nouveaux Agents

### `DevOps Agent`

**Chemin** : `.github/agents/devops.md`

**Déclenchement** : Audit Docker, docker-compose, Nginx, CI/CD, variables d'environnement.

**Fonctionnalités** :
- Vérification des Dockerfiles (multi-stage, sécurité)
- Audit docker-compose (services, healthchecks, networks)
- Configuration Nginx (reverse proxy, headers sécurité)
- Gestion des secrets et variables d'environnement
- Workflows CI/CD GitHub Actions

**Exemples de prompts** :
- "Audite la configuration Docker du projet"
- "Vérifie la sécurité des images Docker"
- "Propose un workflow CI/CD complet"

---

### `Quality Agent`

**Chemin** : `.github/agents/quality.md`

**Déclenchement** : Audit de la qualité du code, couverture de tests, dépendances.

**Fonctionnalités** :
- Vérification de la couverture de tests (backend/frontend)
- Analyse des standards de code (ESLint, Spotless)
- Scan des dépendances et vulnérabilités
- Métriques de maintenabilité

**Exemples de prompts** :
- "Audite la couverture de tests du projet"
- "Analyse les dépendances pour les vulnérabilités"
- "Vérifie les standards de code"

---

### `API Designer Agent`

**Chemin** : `.github/agents/api-designer.md`

**Déclenchement** : Conception et audit des APIs REST, documentation OpenAPI.

**Fonctionnalités** :
- Validation des conventions REST
- Documentation OpenAPI/Swagger
- Détection des breaking changes
- Stratégies de versioning

**Exemples de prompts** :
- "Audite les endpoints REST du projet"
- "Vérifie la documentation OpenAPI"
- "Détecte les breaking changes entre v1 et v2"

---

## 🆕 Nouveaux Skills Backend

### `backend-testing`

**Chemin** : `.github/skills/backend-testing/SKILL.md`

**Déclenchement** : Création de tests unitaires et d'intégration pour le backend.

**Fonctionnalités** :
- Tests de services avec JUnit 5 et Mockito
- Tests de controllers avec @WebMvcTest
- Tests de repositories avec Testcontainers
- Configuration JaCoCo pour la couverture

**Exemples de prompts** :
- "Crée les tests unitaires pour ProductService"
- "Génère les tests d'intégration pour le ProductController"
- "Ajoute les tests de repository avec Testcontainers"

---

### `backend-migration`

**Chemin** : `.github/skills/backend-migration/SKILL.md`

**Déclenchement** : Création de migrations SQL avec Flyway.

**Fonctionnalités** :
- Migrations versionnées (V1__, V2__...)
- Création de tables avec relations
- Modification de schéma (add column, index)
- Scripts de seed data

**Exemples de prompts** :
- "Crée une migration pour la table products"
- "Ajoute une colonne status à la table orders"
- "Génère les index pour la recherche"

---

### `backend-exception`

**Chemin** : `.github/skills/backend-exception/SKILL.md`

**Déclenchement** : Gestion des exceptions et erreurs API.

**Fonctionnalités** :
- Exceptions métier personnalisées
- GlobalExceptionHandler
- Structure de réponse d'erreur standardisée
- Gestion des erreurs de validation

**Exemples de prompts** :
- "Crée les exceptions pour le domaine Order"
- "Génère un GlobalExceptionHandler complet"
- "Ajoute la gestion des erreurs de validation"

---

### `backend-dto-mapper`

**Chemin** : `.github/skills/backend-dto-mapper/SKILL.md`

**Déclenchement** : Création de mappers entre entités et DTOs.

**Fonctionnalités** :
- MapStruct avec configuration Spring
- Mapping manuel (alternative)
- Relations et nested objects
- Méthodes de mise à jour

**Exemples de prompts** :
- "Crée un mapper MapStruct pour Product"
- "Génère les méthodes de mapping pour Order"
- "Ajoute le mapping des relations"

---

## 🆕 Nouveaux Skills Frontend

### `frontend-testing`

**Chemin** : `.github/skills/frontend-testing/SKILL.md`

**Déclenchement** : Création de tests pour composants et hooks React.

**Fonctionnalités** :
- Tests de composants avec Testing Library
- Tests de hooks avec renderHook
- Mocking API avec MSW
- Configuration Vitest

**Exemples de prompts** :
- "Crée les tests pour ProductCard"
- "Génère les tests du hook useProducts"
- "Configure MSW pour mocker l'API"

---

### `frontend-form`

**Chemin** : `.github/skills/frontend-form/SKILL.md`

**Déclenchement** : Création de formulaires avec validation.

**Fonctionnalités** :
- Formulaires avec react-hook-form
- Validation avec zod
- Composants de formulaire réutilisables
- Gestion des erreurs et états

**Exemples de prompts** :
- "Crée un formulaire de création de produit"
- "Génère le schéma zod pour l'inscription"
- "Ajoute un formulaire avec champs dynamiques"

---

### `frontend-routing`

**Chemin** : `.github/skills/frontend-routing/SKILL.md`

**Déclenchement** : Configuration du routing avec React Router.

**Fonctionnalités** :
- Configuration des routes avec lazy loading
- Routes protégées et layouts
- Gestion des paramètres URL
- Navigation et breadcrumbs

**Exemples de prompts** :
- "Configure les routes du module produits"
- "Ajoute les routes protégées pour l'admin"
- "Crée un composant ProtectedRoute"

---

### `frontend-state`

**Chemin** : `.github/skills/frontend-state/SKILL.md`

**Déclenchement** : Gestion d'état global avec Zustand.

**Fonctionnalités** :
- Stores Zustand avec persistence
- Slices pour grandes applications
- Intégration avec Immer
- Stores pour cart, auth, UI

**Exemples de prompts** :
- "Crée un store pour le panier d'achat"
- "Génère le store d'authentification"
- "Ajoute un store UI pour les toasts"

---

## 🆕 Skills Transverses

### `docker-compose`

**Chemin** : `.github/skills/docker-compose/SKILL.md`

**Déclenchement** : Configuration de l'infrastructure Docker.

**Fonctionnalités** :
- Configuration dev/prod
- Services additionnels (Redis, MinIO, RabbitMQ)
- Dockerfiles optimisés
- Configuration Nginx

**Exemples de prompts** :
- "Ajoute Redis au docker-compose"
- "Configure Nginx en reverse proxy"
- "Optimise les Dockerfiles pour la production"

---

### `feature-spec`

**Chemin** : `.github/skills/feature-spec/SKILL.md`

**Déclenchement** : Création de spécifications de features.

**Fonctionnalités** :
- Template de spécification complet
- User stories avec critères d'acceptation
- Conception technique (backend/frontend)
- Scénarios de test

**Exemples de prompts** :
- "Crée la spec pour la gestion des produits"
- "Génère les user stories pour le panier"
- "Documente l'architecture de la feature"

---

### `github-actions`

**Chemin** : `.github/skills/github-actions/SKILL.md`

**Déclenchement** : Création de workflows CI/CD.

**Fonctionnalités** :
- Pipeline CI complète (test, build)
- Déploiement staging/production
- Scanning de sécurité (CodeQL, Trivy)
- Release automatique

**Exemples de prompts** :
- "Crée un workflow CI complet"
- "Ajoute le déploiement automatique"
- "Configure le scanning de sécurité"

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

