#!/bin/bash
# ===========================================
# dev.sh — Lancer l'environnement de dev
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Vérifier que .env existe
if [ ! -f .env ]; then
    echo "❌ Fichier .env manquant. Lancez d'abord : ./setup.sh"
    exit 1
fi

# Vérifier que le symlink backend/.env existe
if [ ! -L backend/.env ]; then
    echo "🔗 Création du symlink backend/.env..."
    ln -sf ../.env backend/.env
fi

case "${1:-help}" in
  db)
    echo "🐘 Démarrage de PostgreSQL..."
    docker compose -f docker/docker-compose.dev.yml --env-file .env up -d
    echo "✅ PostgreSQL démarré sur le port $(grep POSTGRES_PORT .env | cut -d= -f2 || echo '5432')"
    ;;
  backend)
    echo "☕ Démarrage du backend Spring Boot..."
    cd backend && mvn spring-boot:run
    ;;
  frontend)
    echo "⚛️  Démarrage du frontend Vite..."
    cd frontend && npm run dev
    ;;
  all)
    echo "🐘 Démarrage de PostgreSQL..."
    docker compose -f docker/docker-compose.dev.yml --env-file .env up -d
    echo ""
    echo "✅ PostgreSQL démarré."
    echo ""
    echo "Lancez maintenant dans 2 terminaux séparés :"
    echo "   ./dev.sh backend"
    echo "   ./dev.sh frontend"
    ;;
  stop)
    echo "🛑 Arrêt des services Docker..."
    docker compose -f docker/docker-compose.dev.yml --env-file .env down
    echo "✅ Services arrêtés"
    ;;
  help|*)
    echo "Usage: ./dev.sh <commande>"
    echo ""
    echo "Commandes disponibles :"
    echo "  db        Démarre PostgreSQL (Docker)"
    echo "  backend   Démarre le backend Spring Boot (Maven)"
    echo "  frontend  Démarre le frontend Vite (npm)"
    echo "  all       Démarre PostgreSQL + instructions"
    echo "  stop      Arrête les services Docker"
    ;;
esac

