# 📚 Documentation du Projet

Ce répertoire contient la documentation complète du projet : vision, architecture et spécifications des features.

## 📁 Structure

```
docs/
├── README.md                 # Ce fichier (backlog)
├── PROJECT.md                # 🎯 Vision et concept du projet
├── ARCHITECTURE.md           # Architecture technique du projet
├── AI_CONTEXT.md             # Contexte pour les assistants IA
└── features/                 # Spécifications des features
    ├── _TEMPLATE.md          # Template pour nouvelles features
    └── ...                   # Fichiers de features
```

## 🎯 Workflow de documentation

Lors de l'initialisation d'un nouveau projet basé sur ce template :

### Étape 1 : Définir la vision du projet
1. Éditer le fichier [`PROJECT.md`](./PROJECT.md)
2. Remplir la vision, les personas, le domaine métier
3. Définir le périmètre MVP et les features principales

### Étape 2 : Créer les spécifications des features
1. Pour chaque feature identifiée dans `PROJECT.md`
2. Copier `features/_TEMPLATE.md` et créer la spec détaillée
3. Mettre à jour le backlog ci-dessous

## 🚀 Comment ajouter une nouvelle feature

1. Copier le fichier `features/_TEMPLATE.md`
2. Renommer en `features/NOM-DE-LA-FEATURE.md`
3. Remplir les sections du template
4. Mettre à jour le backlog ci-dessous

## 📋 Backlog des Features

### 🔴 À faire (Priorité haute)

| Feature | Description | Statut |
|---------|-------------|--------|
| - | - | - |

### 🟡 Planifié

| Feature | Description | Statut |
|---------|-------------|--------|
| - | - | - |

### 🟢 Terminé

| Feature | Description | Date |
|---------|-------------|------|
| - | - | - |

## 📖 Conventions

### Nommage des fichiers

- Utiliser le kebab-case : `user-authentication.md`
- Préfixer par un numéro pour l'ordre : `001-user-authentication.md` (optionnel)

### Statuts

- 📝 **Draft** : En cours de rédaction
- ✅ **Ready** : Prêt pour le développement
- 🚧 **In Progress** : En cours de développement
- ✔️ **Done** : Terminé
- ❌ **Cancelled** : Annulé

## 🔗 Liens utiles

- [🎯 Vision du projet](./PROJECT.md)
- [Architecture du projet](./ARCHITECTURE.md)
- [Contexte IA](./AI_CONTEXT.md)
- [Instructions Copilot](../.github/copilot-instructions.md)
- [Agents disponibles](../AGENTS.md)
