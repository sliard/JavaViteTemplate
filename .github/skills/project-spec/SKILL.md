---
name: project-spec
description: Generate or fill the project concept document (PROJECT.md). Use this when asked to define the project vision, personas, domain, or MVP scope.
---

# Project Specification Generation

Generate or complete the project vision document following the template standards.

## File Location

```
docs/PROJECT.md
```

## Purpose

The `PROJECT.md` file is the **first document to fill** when starting a new project based on this template. It provides:

- **Vision**: What the project is and why it exists
- **Domain**: Business context and glossary
- **Personas**: User types and their needs
- **Features**: Main functionalities and MVP scope
- **Constraints**: Technical, legal, and performance requirements

## Workflow

```
1. Fill PROJECT.md (vision, personas, domain)
        ↓
2. Create feature specs in docs/features/
        ↓
3. Generate code with Copilot skills
```

## Template Structure

```markdown
# 🎯 Concept du Projet

> 📝 **Statut** : Draft
> 📅 **Date de création** : YYYY-MM-DD
> 👤 **Auteur** : [Nom]

## 📋 Vision du Projet
- Nom du projet
- Pitch (elevator pitch)
- Problème résolu
- Proposition de valeur

## 🏢 Domaine Métier
- Contexte
- Glossaire (termes métier)
- Règles métier principales

## 👥 Personas
- Persona 1: Rôle, Objectifs, Frustrations, Besoins
- Persona 2: ...

## 🚀 Features Principales
- Liste avec priorités (🔴 Haute, 🟡 Moyenne, 🟢 Basse)
- Liens vers les specs détaillées

## 🎯 MVP
- Périmètre inclus
- Hors périmètre (V2+)
- Critères de succès

## ⚠️ Contraintes
- Techniques
- Légales / Conformité
- Performance
- Budget / Délais

## ✅ Checklist d'initialisation
```

## Generation Guidelines

### When asked to create a project concept

1. **Ask clarifying questions** to understand:
   - What is the project about?
   - Who are the main users?
   - What problem does it solve?
   - What are the main features?

2. **Fill the template** with the gathered information

3. **Suggest next steps**: Create feature specs for each main feature

### Example prompts

```
"Aide-moi à remplir le PROJECT.md pour une application de gestion de tâches"

"Crée le concept du projet pour un e-commerce de produits artisanaux"

"Définis les personas pour mon application de suivi fitness"
```

### Example output

```markdown
# 🎯 Concept du Projet

> 📝 **Statut** : Draft
> 📅 **Date de création** : 2026-02-15
> 👤 **Auteur** : Équipe Dev

## 📋 Vision du Projet

### Nom du projet
TaskFlow

### Pitch
Une plateforme de gestion de tâches collaborative permettant aux équipes de suivre leurs projets en temps réel avec une interface intuitive.

### Problème résolu
Les équipes perdent du temps à coordonner leurs tâches entre plusieurs outils (email, chat, tableur). TaskFlow centralise tout en un seul endroit.

### Proposition de valeur
- Interface simple et moderne
- Collaboration en temps réel
- Intégrations avec les outils existants (Slack, GitHub)

## 🏢 Domaine Métier

### Contexte
Gestion de projet agile pour équipes de 2 à 50 personnes.

### Glossaire

| Terme | Définition |
|-------|------------|
| Workspace | Espace de travail d'une équipe |
| Board | Tableau de tâches (type Kanban) |
| Card | Tâche individuelle sur un board |
| Sprint | Période de travail (1-4 semaines) |

### Règles métier principales
1. Un utilisateur peut appartenir à plusieurs workspaces
2. Seuls les admins peuvent inviter de nouveaux membres
3. Les cards archivées sont conservées 90 jours

## 👥 Personas

### Persona 1 : Chef de projet

| Attribut | Description |
|----------|-------------|
| **Rôle** | Manager d'équipe |
| **Objectifs** | Suivre l'avancement global, identifier les blocages |
| **Frustrations** | Manque de visibilité sur la charge de l'équipe |
| **Besoins** | Dashboard de suivi, rapports automatiques |

### Persona 2 : Développeur

| Attribut | Description |
|----------|-------------|
| **Rôle** | Membre de l'équipe |
| **Objectifs** | Savoir quoi faire, collaborer facilement |
| **Frustrations** | Trop de notifications, outils compliqués |
| **Besoins** | Interface simple, intégration GitHub |

## 🚀 Features Principales

| # | Feature | Description | Priorité | Spec |
|---|---------|-------------|----------|------|
| 1 | Authentification | Inscription, connexion, SSO | 🔴 Haute | [001-auth.md](./features/001-auth.md) |
| 2 | Workspaces | Création et gestion d'espaces | 🔴 Haute | [002-workspaces.md](./features/002-workspaces.md) |
| 3 | Boards | Tableaux Kanban | 🔴 Haute | [003-boards.md](./features/003-boards.md) |
| 4 | Cards | Gestion des tâches | 🔴 Haute | [004-cards.md](./features/004-cards.md) |
| 5 | Notifications | Alertes temps réel | 🟡 Moyenne | - |
| 6 | Rapports | Statistiques et exports | 🟢 Basse | - |

## 🎯 MVP

### Périmètre du MVP
- [x] Authentification (email + password)
- [x] Création de workspace
- [x] Boards Kanban basiques
- [x] CRUD des cards

### Hors périmètre (V2)
- SSO (Google, Microsoft)
- Intégrations (Slack, GitHub)
- Rapports avancés
- Application mobile

### Critères de succès

| Critère | Objectif |
|---------|----------|
| Utilisateurs beta | 50 utilisateurs |
| Rétention J+7 | > 40% |
| Temps création card | < 10 secondes |

## ⚠️ Contraintes

### Techniques
- Hébergement cloud (AWS ou GCP)
- Support navigateurs modernes (Chrome, Firefox, Safari)

### Légales / Conformité
- RGPD : données utilisateurs en Europe
- Politique de confidentialité requise

### Performance
- Temps de réponse API < 200ms
- Support 100 utilisateurs simultanés (MVP)

### Budget / Délais
- MVP en 3 mois
- Budget serveur : 100€/mois max
```

## Integration with Feature Specs

After completing `PROJECT.md`, create detailed specs for each feature:

1. Identify features marked as 🔴 Haute in the MVP
2. Use the `feature-spec` skill to generate each spec
3. Update the backlog in `docs/README.md`

## Checklist

Before starting development:

- [ ] Vision is clear and validated
- [ ] Personas are defined with needs
- [ ] MVP scope is agreed upon
- [ ] Main features are listed with priorities
- [ ] Constraints are documented
- [ ] Feature specs are created for MVP features

