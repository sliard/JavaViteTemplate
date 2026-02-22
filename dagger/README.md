# Dagger CI/CD Local

Ce module Dagger permet de tester la pipeline CI/CD GitHub Actions localement avant de pusher.

## Prérequis

- Docker installé et en cours d'exécution
- Dagger CLI installé (`curl -fsSL https://dl.dagger.io/dagger/install.sh | sh`)

## Installation sur Debian

```bash
# Installer Dagger CLI
curl -fsSL https://dl.dagger.io/dagger/install.sh | BIN_DIR=$HOME/.local/bin sh

# Ajouter au PATH (ajouter dans ~/.bashrc pour persister)
export PATH="$HOME/.local/bin:$PATH"

# Vérifier l'installation
dagger version
```

## Commandes disponibles

Toutes les commandes doivent être exécutées depuis le répertoire `dagger/`.

### 🧪 Tests

```bash
# Tests backend uniquement (avec PostgreSQL)
dagger call backend-test --source=..

# Tests frontend uniquement (lint, type-check, tests)
dagger call frontend-test --source=..

# Pipeline CI complète (backend + frontend)
dagger call ci --source=..

# Reproduire EXACTEMENT le workflow GitHub Actions ci.yml
# (tests + builds + images Docker)
dagger call github-actions-ci --source=..
```

### 🔨 Build

```bash
# Construire le JAR backend
dagger call backend-build --source=.. export --path=./backend.jar

# Construire les assets frontend
dagger call frontend-build --source=.. export --path=./dist

# Construire les images Docker
dagger call build-images --source=..
```

### 🔒 Sécurité

```bash
# Vérifications de sécurité (OWASP + npm audit)
dagger call security-check --source=..
```

### 📝 Linting

```bash
# Linting frontend (ESLint)
dagger call lint --source=..
```

### 🚀 Pipeline complète

```bash
# Exécuter TOUTE la pipeline (CI + Build images)
dagger call all --source=..
```

### 🖥️ Développement

```bash
# Démarrer l'application pour le développement
dagger call serve --source=.. up
```

## Exemples d'utilisation

### Avant un commit

```bash
cd dagger
dagger call lint --source=..
```

### Avant un push

```bash
cd dagger
dagger call ci --source=..
```

### Avant une release

```bash
cd dagger
dagger call all --source=..
```

## Fonctions disponibles

| Fonction | Description |
|----------|-------------|
| `backend-test` | Exécute `mvn verify` avec PostgreSQL |
| `backend-build` | Compile le backend (produit le JAR) |
| `frontend-test` | Lint + type-check + tests frontend |
| `frontend-build` | Build production du frontend |
| `ci` | Pipeline CI complète |
| `github-actions-ci` | ⭐ Reproduit exactement le workflow GitHub Actions ci.yml |
| `github-actions-security` | ⭐ Reproduit exactement le workflow GitHub Actions security.yml |
| `build-backend-image` | Construit l'image Docker backend |
| `build-frontend-image` | Construit l'image Docker frontend |
| `build-images` | Construit les deux images Docker |
| `owasp-check` | OWASP Dependency Check sur le backend |
| `npm-audit` | npm audit sur le frontend |
| `trivy-scan` | Trivy container vulnerability scan |
| `lint` | ESLint frontend |
| `all` | Pipeline complète |
| `serve` | Démarre l'app pour le dev |

## Cache

Dagger utilise des volumes de cache pour accélérer les builds :

- `maven-cache` : Dépendances Maven (~/.m2)
- `node-modules` : Modules Node.js
- `npm-cache` : Cache npm

Les builds suivants seront beaucoup plus rapides !

## Troubleshooting

### Docker non démarré

```bash
sudo systemctl start docker
```

### Permissions Docker

```bash
sudo usermod -aG docker $USER
# Puis se reconnecter
```

### Nettoyage du cache Dagger

```bash
dagger cache prune
```

