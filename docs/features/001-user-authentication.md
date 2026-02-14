# Feature : Authentification Utilisateur

> 📝 **Statut** : Ready
> 
> 📅 **Date de création** : 2025-02-14
> 
> 👤 **Auteur** : Template

## 📋 Résumé

Implémenter un système d'authentification complet avec inscription, connexion, et gestion des sessions via JWT. Cette feature est la base de toute application nécessitant des utilisateurs authentifiés.

## 🎯 Objectifs

- [ ] Permettre aux utilisateurs de s'inscrire
- [ ] Permettre aux utilisateurs de se connecter
- [ ] Gérer les tokens JWT (access + refresh)
- [ ] Protéger les routes frontend
- [ ] Sécuriser les endpoints API

## 👥 User Stories

### US1 : Inscription
**En tant que** visiteur,  
**je veux** créer un compte avec mon email et mot de passe,  
**afin de** pouvoir accéder aux fonctionnalités de l'application.

**Critères d'acceptation :**
- [ ] Formulaire avec email, mot de passe, confirmation
- [ ] Validation email unique
- [ ] Mot de passe sécurisé (min 8 caractères, 1 majuscule, 1 chiffre)
- [ ] Message de confirmation après inscription
- [ ] Redirection vers la page de connexion

### US2 : Connexion
**En tant que** utilisateur inscrit,  
**je veux** me connecter avec mon email et mot de passe,  
**afin de** accéder à mon espace personnel.

**Critères d'acceptation :**
- [ ] Formulaire de connexion
- [ ] Message d'erreur si identifiants incorrects
- [ ] Redirection vers le dashboard après connexion
- [ ] Option "Se souvenir de moi"

### US3 : Déconnexion
**En tant que** utilisateur connecté,  
**je veux** pouvoir me déconnecter,  
**afin de** sécuriser mon compte.

**Critères d'acceptation :**
- [ ] Bouton de déconnexion visible
- [ ] Suppression du token côté client
- [ ] Redirection vers la page d'accueil

### US4 : Persistence de session
**En tant que** utilisateur connecté,  
**je veux** rester connecté entre les visites,  
**afin de** ne pas avoir à me reconnecter à chaque fois.

**Critères d'acceptation :**
- [ ] Token stocké de manière sécurisée
- [ ] Refresh automatique du token
- [ ] Déconnexion si token expiré et refresh impossible

## 🏗️ Conception technique

### Backend

#### Entités
```
User
├── id: UUID
├── email: String (unique)
├── password: String (hashed)
├── firstName: String
├── lastName: String
├── role: Role (enum: USER, ADMIN)
├── enabled: Boolean
├── createdAt: Instant
└── updatedAt: Instant
```

#### Endpoints API
| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| POST | `/api/auth/register` | Inscription | ❌ |
| POST | `/api/auth/login` | Connexion | ❌ |
| POST | `/api/auth/refresh` | Rafraîchir token | ❌ |
| POST | `/api/auth/logout` | Déconnexion | ✅ |
| GET | `/api/auth/me` | Profil utilisateur | ✅ |

#### DTOs
```java
// Requests
RegisterRequest(email, password, firstName, lastName)
LoginRequest(email, password)
RefreshTokenRequest(refreshToken)

// Responses
AuthResponse(accessToken, refreshToken, expiresIn)
UserResponse(id, email, firstName, lastName, role)
```

#### Services
- `AuthService` : Logique d'authentification
- `JwtService` : Génération et validation des tokens
- `UserService` : Gestion des utilisateurs

### Frontend

#### Composants
- `LoginForm` : Formulaire de connexion
- `RegisterForm` : Formulaire d'inscription
- `ProtectedRoute` : HOC pour routes protégées
- `AuthProvider` : Context d'authentification

#### Routes
| Route | Composant | Protection |
|-------|-----------|------------|
| `/login` | LoginPage | Public |
| `/register` | RegisterPage | Public |
| `/dashboard` | DashboardPage | Protégé |

#### Hooks
- `useAuth` : Accès au contexte d'authentification
- `useLogin` : Mutation de connexion
- `useRegister` : Mutation d'inscription

## 📊 Données de test

```json
{
  "user": {
    "email": "test@example.com",
    "password": "Password123!",
    "firstName": "John",
    "lastName": "Doe"
  }
}
```

## ⚠️ Risques et dépendances

| Risque / Dépendance | Impact | Mitigation |
|---------------------|--------|------------|
| Fuite de token | Élevé | Utiliser httpOnly cookies |
| Brute force | Moyen | Rate limiting sur /login |

## 📝 Notes

- Considérer OAuth2 pour une future version
- Ajouter la vérification d'email dans une prochaine itération
- Prévoir la récupération de mot de passe

## ✅ Definition of Done

- [ ] Endpoints backend implémentés et testés
- [ ] Tests unitaires services (>80%)
- [ ] Tests d'intégration endpoints
- [ ] Composants React implémentés
- [ ] Context d'authentification fonctionnel
- [ ] Routes protégées opérationnelles
- [ ] Documentation API OpenAPI
- [ ] Tests E2E du parcours utilisateur

