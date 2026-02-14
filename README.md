# JavaViteTemplate

Template de projet fullstack moderne avec **Java/Spring Boot** pour le backend et **React/Vite** pour le frontend, incluant une configuration Docker complète.

## 🚀 Stack Technique

### Backend
| Technologie | Version | Description |
|-------------|---------|-------------|
| Java | 21 LTS | Langage principal |
| Spring Boot | 3.4.x | Framework backend |
| Spring Security | 6.x | Authentification & autorisation |
| Spring Data JPA | 3.4.x | Accès aux données |
| PostgreSQL | 16 | Base de données |
| Maven | 3.9.x | Gestionnaire de dépendances |

### Frontend
| Technologie | Version | Description |
|-------------|---------|-------------|
| Node.js | 22 LTS | Runtime JavaScript |
| React | 19.x | Bibliothèque UI |
| Vite | 6.x | Build tool |
| TypeScript | 5.x | Typage statique |

### Infrastructure
| Technologie | Version | Description |
|-------------|---------|-------------|
| Docker | 24+ | Containerisation |
| Docker Compose | 2.x | Orchestration locale |
| Nginx | Alpine | Serveur web frontend |

## 📁 Structure du Projet

```
├── backend/                    # Projet Spring Boot (à générer)
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/example/
│   │   │   │       ├── config/         # Configuration Spring
│   │   │   │       ├── controller/     # REST Controllers
│   │   │   │       ├── dto/            # Data Transfer Objects
│   │   │   │       ├── entity/         # Entités JPA
│   │   │   │       ├── repository/     # Repositories JPA
│   │   │   │       ├── security/       # Configuration JWT
│   │   │   │       ├── service/        # Services métier
│   │   │   │       └── Application.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   └── pom.xml
│
├── frontend/                   # Projet React/Vite (à générer)
│   ├── src/
│   │   ├── components/         # Composants React
│   │   ├── pages/              # Pages/Routes
│   │   ├── hooks/              # Custom hooks
│   │   ├── services/           # Appels API
│   │   ├── store/              # État global
│   │   ├── types/              # Types TypeScript
│   │   └── App.tsx
│   ├── package.json
│   └── vite.config.ts
│
├── docker/
│   ├── nginx/                  # Configuration Nginx
│   └── init-db/                # Scripts SQL d'initialisation
│
├── .github/
│   ├── copilot-instructions.md # Instructions pour GitHub Copilot
│   └── skills/                 # Skills Copilot par domaine
│
├── docker-compose.yml          # Production (DB + Backend + Frontend)
├── docker-compose.dev.yml      # Développement (DB uniquement)
├── Dockerfile.backend          # Build Spring Boot
├── Dockerfile.frontend         # Build React + Nginx
└── AGENTS.md                   # Documentation des agents Copilot
```

## 🛠️ Démarrage Rapide

### Prérequis
- Docker & Docker Compose
- Java 21 (pour le développement local)
- Node.js 22 LTS (pour le développement local)
- Maven 3.9+ (pour le développement local)

### Mode Développement

1. **Démarrer la base de données**
   ```bash
   docker compose -f docker-compose.dev.yml up -d
   ```

2. **Démarrer le backend** (dans le dossier `backend/`)
   ```bash
   cd backend
   mvn spring-boot:run
   ```

3. **Démarrer le frontend** (dans le dossier `frontend/`)
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

4. **Accès**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:8080/api
   - PostgreSQL: localhost:5432

### Mode Production

1. **Configurer les variables d'environnement**
   ```bash
   cp .env.example .env
   # Éditer .env avec les valeurs de production
   ```

2. **Lancer l'ensemble**
   ```bash
   docker compose up -d --build
   ```

3. **Accès**
   - Application: http://localhost
   - API: http://localhost/api

## 🔐 Sécurité

### Authentification JWT (Backend)

Le template préconise l'utilisation de **Spring Security avec JWT** :

- Endpoints publics : `/api/auth/**`
- Endpoints protégés : `/api/**` (nécessite un token JWT)
- Refresh token : Rotation automatique recommandée
- Stockage : HttpOnly cookies (recommandé) ou localStorage

### Variables sensibles

⚠️ **Ne jamais commiter le fichier `.env`** - Utiliser `.env.example` comme référence.

Variables critiques à changer en production :
- `POSTGRES_PASSWORD`
- `JWT_SECRET` (minimum 256 bits)

## 📚 Documentation Copilot

Ce template inclut des instructions pour GitHub Copilot :

- **AGENTS.md** : Description des agents disponibles et leurs capacités
- **.github/copilot-instructions.md** : Conventions et bonnes pratiques du projet
- **.github/skills/** : Skills spécifiques par domaine

## 🤝 Utilisation avec Copilot

Exemples de prompts efficaces :

```
Crée une entité JPA "Product" avec id, name, price et description
```

```
Génère un CRUD complet pour l'entité User avec authentification JWT
```

```
Crée un composant React "ProductCard" avec TypeScript
```

```
Configure Spring Security avec JWT pour ce projet
```

## 📝 Commandes Utiles

### Docker
```bash
# Logs
docker compose logs -f [service]

# Rebuild
docker compose up -d --build

# Nettoyage complet
docker compose down -v
```

### Backend
```bash
# Tests
mvn test

# Build
mvn clean package -DskipTests

# Formatage
mvn spotless:apply
```

### Frontend
```bash
# Tests
npm run test

# Build
npm run build

# Lint
npm run lint
```

## 📄 Licence

MIT

