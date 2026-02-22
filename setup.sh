#!/bin/bash
# ===========================================
# setup.sh — Initialisation du projet
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 Initialisation du projet..."
echo ""

# 1. Créer le .env depuis .env.example
echo "📋 Fichier .env..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "   ✅ .env créé depuis .env.example"
    echo "   ⚠️  Pensez à éditer .env avec vos valeurs"
else
    echo "   ⏭️  .env existe déjà"
fi

# 2. Créer le symlink backend/.env -> ../.env
echo "🔗 Symlink backend/.env..."
if [ ! -L backend/.env ]; then
    ln -sf ../.env backend/.env
    echo "   ✅ backend/.env -> ../.env"
else
    echo "   ⏭️  Symlink existe déjà"
fi

# 3. Installer les dépendances frontend
echo "📦 Dépendances frontend..."
if [ ! -d frontend/node_modules ]; then
    cd frontend && npm install && cd ..
    echo "   ✅ node_modules installé"
else
    echo "   ⏭️  node_modules existe déjà"
fi

# 4. Télécharger les dépendances Maven
echo "☕ Dépendances backend..."
cd backend && mvn dependency:go-offline -q 2>/dev/null && cd ..
echo "   ✅ Dépendances Maven téléchargées"

echo ""
echo "============================================"
echo "✅ Setup terminé !"
echo ""
echo "Pour démarrer le projet :"
echo "   ./dev.sh db         → Démarre PostgreSQL"
echo "   ./dev.sh backend    → Démarre le backend"
echo "   ./dev.sh frontend   → Démarre le frontend"
echo "============================================"

