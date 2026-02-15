# AI_CONTEXT.md

> Ce fichier fournit le contexte essentiel aux assistants IA (GitHub Copilot, ChatGPT, Claude, etc.) pour comprendre et contribuer efficacement à ce projet.

## 🎯 Contexte Métier

> **Important pour les IA** : Pour comprendre le contexte métier spécifique de ce projet (vision, personas, domaine, MVP), consultez en priorité le fichier [`PROJECT.md`](./PROJECT.md).
>
> Ce fichier `AI_CONTEXT.md` décrit l'aspect **technique** du template, tandis que `PROJECT.md` décrit le **quoi** et le **pourquoi** du projet spécifique.

---

## 📋 Résumé du Projet

**JavaViteTemplate** est un template de projet fullstack moderne conçu pour accélérer le développement d'applications web. Il combine un backend robuste en Java/Spring Boot avec un frontend réactif en React/TypeScript.

### Objectif
Fournir une base de code prête à l'emploi avec :
- Une architecture clean et des conventions établies
- Une configuration Docker complète (dev et prod)
- Une authentification JWT intégrée
- Des instructions IA pour une assistance optimale

---

## 🏗️ Stack Technique

### Backend
| Technologie | Version | Rôle |
|-------------|---------|------|
| Java | 21 LTS | Langage principal |
| Spring Boot | 3.4.x | Framework applicatif |
| Spring Security | 6.x | Authentification JWT |
| Spring Data JPA | 3.4.x | ORM et accès données |
| PostgreSQL | 16 | Base de données |
| Maven | 3.9.x | Build et dépendances |

### Frontend
| Technologie | Version | Rôle |
|-------------|---------|------|
| Node.js | 22 LTS | Runtime |
| React | 19.x | Bibliothèque UI |
| Vite | 6.x | Build tool |
| TypeScript | 5.x | Typage statique |

### Infrastructure
| Technologie | Version | Rôle |
|-------------|---------|------|
| Docker | 24+ | Containerisation |
| Docker Compose | 2.x | Orchestration |
| Nginx | Alpine | Reverse proxy |

---

## 📁 Structure du Projet

```
JavaViteTemplate/
├── backend/                    # API Spring Boot
│   └── src/main/java/com/example/
│       ├── config/             # Configuration Spring
│       ├── controller/         # REST Controllers
│       ├── dto/                # Data Transfer Objects
│       ├── entity/             # Entités JPA
│       ├── repository/         # Repositories JPA
│       ├── security/           # JWT & Spring Security
│       ├── service/            # Logique métier
│       └── Application.java
│
├── frontend/                   # Application React
│   └── src/
│       ├── components/         # Composants réutilisables
│       ├── pages/              # Pages/Routes
│       ├── hooks/              # Custom hooks
│       ├── services/           # Appels API
│       ├── store/              # État global
│       ├── types/              # Types TypeScript
│       └── App.tsx
│
├── docker/
│   ├── docker-compose.yml      # Production complète
│   ├── docker-compose.dev.yml  # Dev (PostgreSQL seul)
│   ├── Dockerfile.backend      # Build Spring Boot
│   ├── Dockerfile.frontend     # Build React + Nginx
│   ├── nginx/                  # Config Nginx
│   └── init-db/                # Scripts SQL init
│
├── .github/
│   ├── copilot-instructions.md # Conventions Copilot
│   ├── agents/                 # Agents IA spécialisés
│   ├── skills/                 # Skills par domaine
│   └── hooks/                  # Git hooks
│
├── AGENTS.md                   # Documentation agents IA
├── .env.example                # Template variables d'env
└── README.md                   # Documentation principale
```

---

## 🎯 Architecture et Patterns

### Backend - Architecture en Couches

```
Controller  →  Service  →  Repository  →  Entity
    ↓             ↓            ↓            ↓
  REST API    Business    Data Access   Database
              Logic       (JPA)         (PostgreSQL)
```

**Flux de données :**
1. **Controller** : Reçoit les requêtes HTTP, valide les DTOs
2. **Service** : Contient la logique métier, gère les transactions
3. **Repository** : Interface JPA pour l'accès aux données
4. **Entity** : Mapping objet-relationnel avec la base

### Frontend - Architecture Fonctionnelle

```
Pages  →  Components  →  Hooks  →  Services  →  API
```

**Principes :**
- Composants fonctionnels uniquement (pas de classes)
- État géré via hooks personnalisés
- Séparation logique UI / appels API

---

## 📐 Conventions de Code

### Backend (Java/Spring)

| Élément | Convention | Exemple |
|---------|------------|---------|
| Entités | UUID + timestamps | `@GeneratedValue(strategy = GenerationType.UUID)` |
| Tables | Pluriel, snake_case | `@Table(name = "products")` |
| DTOs | Records avec suffixes | `ProductRequest`, `ProductResponse` |
| Services | Interface + Impl | `ProductService` + `ProductServiceImpl` |
| Endpoints | `/api/` prefix | `@RequestMapping("/api/products")` |
| Transactions | ReadOnly par défaut | `@Transactional(readOnly = true)` |

### Frontend (React/TypeScript)

| Élément | Convention | Exemple |
|---------|------------|---------|
| Composants | PascalCase, export nommé | `export const ProductCard: React.FC<Props>` |
| Props | Interface avec suffixe | `interface ProductCardProps` |
| Hooks | Préfixe `use` | `useProducts()`, `useAuth()` |
| Services | Objet avec méthodes async | `productService.findAll()` |
| Types | Interface pour modèles | `interface Product { id: string; }` |

---

## 🔐 Sécurité

### Authentification JWT

- **Endpoints publics** : `/api/auth/**`, `/api/public/**`
- **Endpoints protégés** : Tous les autres `/api/**`
- **Stockage token** : HttpOnly cookies (recommandé) ou localStorage
- **Durée token** : 24h par défaut (configurable)

### Variables Sensibles

| Variable | Description | Criticité |
|----------|-------------|-----------|
| `POSTGRES_PASSWORD` | Mot de passe BDD | 🔴 Critique |
| `JWT_SECRET` | Clé de signature JWT | 🔴 Critique |
| `SPRING_PROFILES_ACTIVE` | Profil Spring | 🟡 Important |

⚠️ **Ne jamais commiter `.env`** - Utiliser `.env.example` comme référence.

---

## 🐳 Docker

### Mode Développement
```bash
# Lance PostgreSQL uniquement
docker compose -f docker/docker-compose.dev.yml up -d
```

### Mode Production
```bash
# Lance l'ensemble (PostgreSQL + Backend + Frontend)
docker compose -f docker/docker-compose.yml up -d --build
```

### Services et Ports

| Service | Container | Port | URL |
|---------|-----------|------|-----|
| PostgreSQL | app-postgres | 5432 | - |
| Backend | app-backend | 8080 | http://localhost:8080/api |
| Frontend | app-frontend | 80/443 | http://localhost |

---

## 🤖 Assistance IA

### Agents Disponibles

| Agent | Fichier | Rôle |
|-------|---------|------|
| Architecte Backend | `.github/agents/backend-architect.md` | Audit architecture Spring Boot |

### Skills Disponibles

| Domaine | Skill | Description |
|---------|-------|-------------|
| Backend | `backend-entity` | Génération entités JPA |
| Backend | `backend-service` | Génération services/repositories |
| Backend | `backend-controller` | Génération controllers REST |
| Backend | `backend-security` | Configuration JWT/Security |
| Frontend | `frontend-component` | Génération composants React |
| Frontend | `frontend-hooks` | Génération custom hooks |
| Frontend | `frontend-services` | Génération services API |
| Frontend | `frontend-auth` | Configuration authentification |

### Prompts Efficaces

```
# Backend
"Crée une entité JPA Product avec id, name, price et description"
"Génère un service CRUD pour l'entité User"
"Configure Spring Security avec JWT"

# Frontend
"Crée un composant ProductCard avec TypeScript"
"Génère un hook useProducts pour fetcher les produits"
"Configure le contexte d'authentification React"
```

---

## 📝 Fichiers de Configuration Clés

| Fichier | Emplacement | Description |
|---------|-------------|-------------|
| `copilot-instructions.md` | `.github/` | Conventions complètes du projet |
| `AGENTS.md` | Racine | Documentation agents/skills |
| `.env.example` | Racine | Template variables d'environnement |
| `application.yml` | `backend/src/main/resources/` | Config Spring Boot |
| `vite.config.ts` | `frontend/` | Config Vite |

---

## ✅ Checklist Nouveau Code

### Backend
- [ ] Entité avec UUID et timestamps (`createdAt`, `updatedAt`)
- [ ] DTOs Request/Response séparés
- [ ] Validation Bean Validation (`@NotBlank`, `@NotNull`, etc.)
- [ ] Service avec interface + implémentation
- [ ] `@Transactional` approprié
- [ ] Documentation OpenAPI (`@Tag`, `@Operation`)
- [ ] Tests unitaires

### Frontend
- [ ] Types TypeScript définis
- [ ] Props interface pour les composants
- [ ] Gestion loading/error/data dans les hooks
- [ ] Export nommé (pas de `default export`)
- [ ] Responsive design

---

## 🔗 Ressources

- **Documentation Spring Boot** : https://docs.spring.io/spring-boot/docs/current/reference/html/
- **Documentation React** : https://react.dev/
- **Documentation Vite** : https://vitejs.dev/
- **Spring Security JWT** : https://docs.spring.io/spring-security/reference/

