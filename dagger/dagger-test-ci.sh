#!/bin/bash
# Script pour tester la CI GitHub Actions localement avec Dagger
# Ce script reproduit exactement le workflow GitHub Actions ci.yml

set -e

cd "$(dirname "$0")"

echo "🚀 Testing GitHub Actions CI workflow locally with Dagger..."
echo ""
echo "This will reproduce all jobs from .github/workflows/ci.yml:"
echo "  1. Backend Tests (with PostgreSQL)"
echo "  2. Frontend Tests (lint, type-check, tests)"
echo "  3. Build Verification (backend JAR + frontend dist)"
echo "  4. Docker Build (backend + frontend images)"
echo ""
echo "⏳ This may take a few minutes on first run (downloads dependencies)..."
echo "   Subsequent runs will be much faster thanks to caching!"
echo ""

dagger call github-actions-ci --source=..

echo ""
echo "✅ GitHub Actions CI workflow completed successfully!"
echo ""
echo "💡 You can now safely push your code - the GitHub Actions workflow will pass!"

