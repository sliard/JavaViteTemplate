---
name: feature-spec
description: Generate feature specification documents following the project template. Use this when asked to create feature specs, user stories, or technical designs.
---

# Feature Specification Generation

Generate feature specifications following the project documentation standards.

## File Location

```
docs/features/
├── _TEMPLATE.md          # Template reference
├── 001-user-authentication.md
├── 002-product-management.md
├── 003-order-processing.md
└── ...
```

## Naming Convention

```
{number}-{feature-name}.md

Examples:
- 001-user-authentication.md
- 002-product-catalog.md
- 003-shopping-cart.md
- 004-order-management.md
- 005-payment-integration.md
```

## Feature Specification Template

```markdown
# Feature : [Nom de la Feature]

> 📝 **Statut** : Draft | Ready | In Progress | Done | Cancelled
> 
> 📅 **Date de création** : YYYY-MM-DD
> 
> 👤 **Auteur** : [Nom]
> 
> 🏷️ **Tags** : backend, frontend, api, security

## 📋 Résumé

_Description courte de la feature en 2-3 phrases expliquant le besoin métier et la valeur apportée._

## 🎯 Objectifs

- [ ] Objectif mesurable 1
- [ ] Objectif mesurable 2
- [ ] Objectif mesurable 3

## 👥 User Stories

### US1 : [Titre de l'action utilisateur]

**En tant que** [type d'utilisateur],  
**je veux** [action/fonctionnalité],  
**afin de** [bénéfice/valeur].

**Critères d'acceptation :**
- [ ] Critère vérifiable 1
- [ ] Critère vérifiable 2
- [ ] Critère vérifiable 3

**Règles métier :**
- Règle 1
- Règle 2

---

### US2 : [Titre de l'action utilisateur]

**En tant que** [type d'utilisateur],  
**je veux** [action/fonctionnalité],  
**afin de** [bénéfice/valeur].

**Critères d'acceptation :**
- [ ] Critère 1
- [ ] Critère 2

---

## 🏗️ Conception Technique

### Backend

#### Entités

```
EntityName
├── id: UUID (PK)
├── field1: Type (contraintes)
├── field2: Type (contraintes)
├── relation: RelatedEntity (FK)
├── createdAt: Instant
└── updatedAt: Instant
```

#### Endpoints API

| Méthode | Endpoint | Description | Auth | Rôles |
|---------|----------|-------------|------|-------|
| GET | `/api/resources` | Liste paginée | ✅ | USER |
| GET | `/api/resources/{id}` | Détail | ✅ | USER |
| POST | `/api/resources` | Création | ✅ | ADMIN |
| PUT | `/api/resources/{id}` | Modification | ✅ | ADMIN |
| DELETE | `/api/resources/{id}` | Suppression | ✅ | ADMIN |

#### DTOs

```java
// Request
ResourceRequest(
    @NotBlank String field1,
    @NotNull Type field2
)

// Response
ResourceResponse(
    UUID id,
    String field1,
    Type field2,
    Instant createdAt
)
```

#### Services

| Service | Responsabilité |
|---------|----------------|
| `ResourceService` | Logique métier CRUD |
| `ValidationService` | Règles de validation métier |

#### Exceptions

| Exception | Code HTTP | Cas d'usage |
|-----------|-----------|-------------|
| `ResourceNotFoundException` | 404 | Ressource inexistante |
| `DuplicateResourceException` | 409 | Doublon détecté |
| `InvalidOperationException` | 422 | Règle métier violée |

---

### Frontend

#### Composants

| Composant | Type | Description |
|-----------|------|-------------|
| `ResourceList` | Page | Liste avec pagination et filtres |
| `ResourceDetail` | Page | Vue détaillée |
| `ResourceForm` | Component | Formulaire création/édition |
| `ResourceCard` | Component | Carte de preview |

#### Routes

| Route | Composant | Auth |
|-------|-----------|------|
| `/resources` | ResourceListPage | ❌ |
| `/resources/:id` | ResourceDetailPage | ❌ |
| `/resources/new` | ResourceCreatePage | ✅ |
| `/resources/:id/edit` | ResourceEditPage | ✅ |

#### State Management

| Store/Hook | Données | Persistence |
|------------|---------|-------------|
| `useResources` | Liste des ressources | Non |
| `useResource(id)` | Ressource unique | Non |

---

## 🔒 Sécurité

### Autorisations

| Action | Visiteur | USER | ADMIN |
|--------|----------|------|-------|
| Voir liste | ✅ | ✅ | ✅ |
| Voir détail | ✅ | ✅ | ✅ |
| Créer | ❌ | ❌ | ✅ |
| Modifier | ❌ | ❌ | ✅ |
| Supprimer | ❌ | ❌ | ✅ |

### Validations

| Champ | Règles |
|-------|--------|
| field1 | Obligatoire, max 255 caractères |
| field2 | Obligatoire, positif |

---

## 🎨 Maquettes / Wireframes

_Liens vers Figma, images, ou descriptions visuelles._

### Liste
```
┌─────────────────────────────────────────┐
│  [Logo]     Resources     [User Menu]   │
├─────────────────────────────────────────┤
│  🔍 Search...        [+ Nouveau]        │
├─────────────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
│  │ Card 1  │  │ Card 2  │  │ Card 3  │  │
│  └─────────┘  └─────────┘  └─────────┘  │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
│  │ Card 4  │  │ Card 5  │  │ Card 6  │  │
│  └─────────┘  └─────────┘  └─────────┘  │
├─────────────────────────────────────────┤
│  < 1 2 3 ... 10 >                       │
└─────────────────────────────────────────┘
```

---

## 📊 Données de Test

```json
{
  "resources": [
    {
      "id": "11111111-1111-1111-1111-111111111111",
      "field1": "Example 1",
      "field2": 100
    },
    {
      "id": "22222222-2222-2222-2222-222222222222",
      "field1": "Example 2",
      "field2": 200
    }
  ]
}
```

---

## 🧪 Scénarios de Test

### Backend

| Scénario | Input | Expected |
|----------|-------|----------|
| Création valide | Request valide | 201 + Resource |
| Création invalide | Champ manquant | 400 + Erreurs |
| Lecture existant | ID valide | 200 + Resource |
| Lecture inexistant | ID inconnu | 404 |

### Frontend

| Scénario | Actions | Expected |
|----------|---------|----------|
| Affichage liste | Load page | Liste paginée |
| Recherche | Saisir texte | Liste filtrée |
| Création | Remplir form, submit | Redirection + toast |

---

## ⚠️ Risques et Dépendances

| Risque / Dépendance | Impact | Mitigation |
|---------------------|--------|------------|
| Feature X doit être terminée | Bloquant | Prioriser X |
| API tierce non disponible | Moyen | Mock en dev |

---

## 📈 Métriques de Succès

| Métrique | Objectif |
|----------|----------|
| Temps de chargement liste | < 500ms |
| Couverture de tests | > 80% |
| Erreurs en production | 0 |

---

## 📝 Notes

_Informations complémentaires, décisions techniques, liens utiles._

---

## 📅 Historique

| Date | Auteur | Modification |
|------|--------|--------------|
| YYYY-MM-DD | Nom | Création initiale |
| YYYY-MM-DD | Nom | Ajout US3 |
```

---

## Exemples de Features

### E-commerce

```markdown
# Feature : Gestion du Panier

## User Stories

### US1 : Ajouter au panier
**En tant que** visiteur,
**je veux** ajouter un produit à mon panier,
**afin de** préparer ma commande.

### US2 : Modifier la quantité
**En tant que** visiteur,
**je veux** modifier la quantité d'un article,
**afin de** ajuster ma commande.

### US3 : Voir le total
**En tant que** visiteur,
**je veux** voir le montant total de mon panier,
**afin de** connaître le prix avant de commander.
```

### SaaS

```markdown
# Feature : Gestion des Abonnements

## User Stories

### US1 : Choisir un plan
**En tant que** utilisateur gratuit,
**je veux** voir les plans disponibles et leurs fonctionnalités,
**afin de** choisir celui qui correspond à mes besoins.

### US2 : Upgrader mon plan
**En tant que** utilisateur,
**je veux** passer à un plan supérieur,
**afin de** débloquer plus de fonctionnalités.

### US3 : Annuler mon abonnement
**En tant que** abonné,
**je veux** pouvoir annuler mon abonnement,
**afin de** ne plus être facturé.
```

---

## Workflow de Création

1. **Créer le fichier** dans `docs/features/` avec le bon numéro
2. **Remplir le résumé** et les objectifs
3. **Définir les User Stories** avec critères d'acceptation
4. **Concevoir l'architecture** (entités, endpoints, composants)
5. **Définir la sécurité** et les validations
6. **Préparer les données de test**
7. **Mettre à jour le backlog** dans `docs/README.md`

