#!/bin/bash

# Script pour lancer les tests E2E en CI/CD
# Usage: ./run-e2e-ci.sh [base_url]

set -e

BASE_URL="${1:-http://localhost:8080}"

echo "=========================================="
echo "Cypress E2E Tests - CI/CD Mode"
echo "=========================================="
echo "Base URL: $BASE_URL"
echo ""

# Vérifier si Node.js est installé
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé"
    exit 1
fi

# Vérifier si npm est installé
if ! command -v npm &> /dev/null; then
    echo "❌ npm n'est pas installé"
    exit 1
fi

# Installer les dépendances si nécessaire
if [ ! -d "node_modules" ]; then
    echo "📦 Installation des dépendances..."
    npm install
fi

# Lancer les tests en mode headless
echo "🧪 Lancement des tests E2E..."
BASE_URL="$BASE_URL" npm run test:e2e

echo ""
echo "✅ Tests E2E terminés avec succès!"
