# Agents GitHub Copilot

Ce document décrit les agents et skills disponibles pour ce projet fullstack Java/Spring Boot + React/Vite.

## 🤖 Vue d'ensemble

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

