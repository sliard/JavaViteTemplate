#!/bin/bash
# Script d'aide pour exécuter les pipelines Dagger
# Usage: ./dagger-ci.sh [command]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAGGER_DIR="$SCRIPT_DIR"
DAGGER_CMD="${DAGGER_CMD:-dagger}"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  🚀 ${GREEN}Dagger CI/CD${NC}                                    ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
}

print_usage() {
    echo -e "${YELLOW}Usage:${NC} $0 [command]"
    echo ""
    echo -e "${YELLOW}Commandes disponibles:${NC}"
    echo -e "  ${GREEN}test${NC}            Exécute la pipeline CI complète (backend + frontend)"
    echo -e "  ${GREEN}backend${NC}         Exécute les tests backend uniquement"
    echo -e "  ${GREEN}frontend${NC}        Exécute les tests frontend uniquement"
    echo -e "  ${GREEN}lint${NC}            Exécute le linting"
    echo -e "  ${GREEN}build${NC}           Construit les images Docker"
    echo -e "  ${GREEN}security${NC}        Exécute les vérifications de sécurité"
    echo -e "  ${GREEN}all${NC}             Exécute toute la pipeline (CI + Build)"
    echo -e "  ${GREEN}serve${NC}           Démarre l'application pour le développement"
    echo -e "  ${GREEN}help${NC}            Affiche cette aide"
    echo ""
    echo -e "${YELLOW}Exemples:${NC}"
    echo "  $0 test        # Avant un push"
    echo "  $0 lint        # Vérifier le code"
    echo "  $0 all         # Pipeline complète"
}

check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}❌ Docker n'est pas démarré. Lancez Docker et réessayez.${NC}"
        echo "   sudo systemctl start docker"
        exit 1
    fi
}

check_dagger() {
    if ! command -v $DAGGER_CMD &> /dev/null; then
        # Essayer avec le chemin local
        if [ -f "$HOME/.local/bin/dagger" ]; then
            DAGGER_CMD="$HOME/.local/bin/dagger"
        else
            echo -e "${RED}❌ Dagger n'est pas installé.${NC}"
            echo "   curl -fsSL https://dl.dagger.io/dagger/install.sh | BIN_DIR=\$HOME/.local/bin sh"
            exit 1
        fi
    fi
}

run_dagger() {
    local cmd="$1"
    echo -e "${BLUE}▶ Exécution: dagger call $cmd --source=..${NC}"
    cd "$DAGGER_DIR"
    $DAGGER_CMD call "$cmd" --source=..
}

main() {
    print_header
    check_docker
    check_dagger

    case "${1:-help}" in
        test|ci)
            echo -e "${GREEN}🧪 Exécution de la pipeline CI...${NC}"
            run_dagger "ci"
            ;;
        backend|backend-test)
            echo -e "${GREEN}☕ Exécution des tests backend...${NC}"
            run_dagger "backend-test"
            ;;
        frontend|frontend-test)
            echo -e "${GREEN}⚛️ Exécution des tests frontend...${NC}"
            run_dagger "frontend-test"
            ;;
        lint)
            echo -e "${GREEN}📝 Exécution du linting...${NC}"
            run_dagger "lint"
            ;;
        build|build-images)
            echo -e "${GREEN}🐳 Construction des images Docker...${NC}"
            run_dagger "build-images"
            ;;
        security|security-check)
            echo -e "${GREEN}🔒 Vérifications de sécurité...${NC}"
            run_dagger "security-check"
            ;;
        all)
            echo -e "${GREEN}🚀 Exécution de la pipeline complète...${NC}"
            run_dagger "all"
            ;;
        serve)
            echo -e "${GREEN}🖥️ Démarrage de l'application...${NC}"
            cd "$DAGGER_DIR"
            $DAGGER_CMD call serve --source=.. up
            ;;
        help|--help|-h)
            print_usage
            ;;
        *)
            echo -e "${RED}❌ Commande inconnue: $1${NC}"
            print_usage
            exit 1
            ;;
    esac
}

main "$@"

