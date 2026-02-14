# Instructions pour les messages de commit Git

Ce fichier définit les conventions de commit pour ce projet, compatibles avec la génération automatique de release notes et la traçabilité JIRA.

## 📐 Format du message de commit

```
<type>(<scope>): <description>

[body]

[footer]
```

### Règles générales

- **Description** : Impératif présent, minuscule, sans point final (max 72 caractères)
- **Body** : Optionnel, explication détaillée du changement
- **Footer** : Références JIRA et breaking changes

---

## 🏷️ Types de commit

| Type       | Description                              | Impact Release Notes    |
|------------|------------------------------------------|-------------------------|
| `feat`     | Nouvelle fonctionnalité                  | ✅ Minor (Features)     |
| `fix`      | Correction de bug                        | ✅ Patch (Bug Fixes)    |
| `docs`     | Documentation uniquement                 | ❌                      |
| `style`    | Formatage, sans changement de code       | ❌                      |
| `refactor` | Refactoring sans ajout de fonctionnalité | ❌                      |
| `perf`     | Amélioration des performances            | ✅ Patch (Performance)  |
| `test`     | Ajout ou modification de tests           | ❌                      |
| `build`    | Changements de build ou dépendances      | ❌                      |
| `ci`       | Configuration CI/CD                      | ❌                      |
| `chore`    | Tâches de maintenance                    | ❌                      |
| `revert`   | Annulation d'un commit précédent         | ✅ Patch (Reverts)      |

---

## 🎯 Scopes recommandés

| Scope      | Description                          |
|------------|--------------------------------------|
| `backend`  | Code Java/Spring Boot                |
| `frontend` | Code React/TypeScript                |
| `api`      | Endpoints REST                       |
| `auth`     | Authentification/Sécurité            |
| `db`       | Base de données/Migrations           |
| `docker`   | Configuration Docker/Infrastructure  |
| `deps`     | Dépendances                          |
| `config`   | Configuration applicative            |

---

## 🔗 Références JIRA

### Format standard

Ajouter la référence JIRA dans le **footer** du commit :

```
feat(api): ajouter endpoint de création de produit

Implémentation du POST /api/products avec validation Bean Validation

Refs: PROJ-123
```

### Mots-clés supportés

| Mot-clé   | Effet dans JIRA                    |
|-----------|------------------------------------|
| `Refs:`   | Crée un lien vers le ticket        |
| `Closes:` | Ferme le ticket (Done)             |
| `Fixes:`  | Ferme le ticket (bug corrigé)      |

### Références multiples

```
fix(backend): corriger la validation des prix

Fixes: PROJ-111
Refs: PROJ-112, PROJ-113
```

---

## ⚠️ Breaking Changes

Pour les changements non rétrocompatibles, utiliser `!` après le scope **ET** détailler dans le footer :

```
feat(api)!: modifier le format de réponse des produits

Le champ price est maintenant un objet avec amount et currency
pour supporter le multi-devise.

BREAKING CHANGE: Le champ `price` (number) devient `price: { amount: number, currency: string }`
Refs: PROJ-200
```

**Impact** : Génère une version **Major** dans le versioning sémantique.

---

## ✅ Exemples complets

### Commit simple

```
fix(frontend): corriger l'affichage du prix sur mobile
```

### Nouvelle fonctionnalité avec JIRA

```
feat(backend): implémenter la pagination des produits

- Ajout du support Pageable dans ProductController
- Création de PageResponse DTO
- Tests unitaires inclus

Refs: PROJ-456
```

### Correction de bug qui ferme un ticket

```
fix(auth): corriger l'expiration du token JWT

Le token expirait immédiatement après création à cause
d'une mauvaise conversion de timestamp.

Fixes: PROJ-789
```

### Breaking change

```
feat(api)!: renommer endpoint /api/users en /api/v2/users

Migration nécessaire pour les clients API existants.
L'ancien endpoint sera supprimé en v3.0.0.

BREAKING CHANGE: L'endpoint /api/users n'existe plus, utiliser /api/v2/users
Refs: PROJ-301
```

### Revert

```
revert: feat(api): ajouter le cache Redis

This reverts commit 1a2b3c4d5e6f.
Le cache causait des incohérences de données.

Refs: PROJ-999
```

---

## 🚫 À éviter

```bash
# ❌ Mauvais
Update code
fix bug  
WIP
PROJ-123
Fixed stuff
commit final

# ✅ Bon
feat(frontend): ajouter le composant ProductCard
fix(api): corriger la validation du prix négatif
docs(readme): mettre à jour les instructions d'installation
```

---

## 🔧 Configuration recommandée

### commitlint (`.commitlintrc.json`)

```json
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "scope-enum": [
      2,
      "always",
      ["backend", "frontend", "api", "auth", "db", "docker", "deps", "config"]
    ],
    "subject-case": [2, "always", "lower-case"],
    "header-max-length": [2, "always", 72],
    "body-max-line-length": [0, "always", 100],
    "footer-max-line-length": [0, "always", 100]
  }
}
```

### Husky + commitlint

```bash
# Installation
npm install -D @commitlint/cli @commitlint/config-conventional husky

# Initialisation Husky
npx husky init

# Hook commit-msg
echo 'npx --no -- commitlint --edit "$1"' > .husky/commit-msg
```

### semantic-release (`.releaserc.json`)

```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/github"
  ]
}
```

---

## 📊 Versioning sémantique

Les commits déterminent automatiquement la version :

| Type de commit      | Version | Exemple         |
|---------------------|---------|-----------------|
| `fix`, `perf`       | Patch   | 1.0.0 → 1.0.1   |
| `feat`              | Minor   | 1.0.0 → 1.1.0   |
| `BREAKING CHANGE`   | Major   | 1.0.0 → 2.0.0   |

---

## ✅ Checklist avant commit

- [ ] Type de commit correct (`feat`, `fix`, etc.)
- [ ] Scope approprié (`backend`, `frontend`, etc.)
- [ ] Description claire et concise (< 72 caractères)
- [ ] Référence JIRA dans le footer si applicable
- [ ] `BREAKING CHANGE` documenté si nécessaire

