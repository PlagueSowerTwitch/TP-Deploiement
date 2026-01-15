#!/bin/bash
# Script de vérification locale avant push
# Vérifie que tout fonctionne avant de pousser sur main

set -e

echo "🔍 Vérification locale de la configuration CI/CD"
echo "=================================================="
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 existe"
        return 0
    else
        echo -e "${RED}✗${NC} $1 manquant"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 existe"
        return 0
    else
        echo -e "${RED}✗${NC} $1 manquant"
        return 1
    fi
}

# Vérifier les fichiers essentiels
echo "📋 Vérification des fichiers..."
check_file "app.py"
check_file "requirements.txt"
check_file "Dockerfile"
check_file "docker-compose.yml"
check_file "package.json"
check_file "cypress.config.js"
check_file "pytest.ini"
check_file "test_app.py"
check_file ".github/workflows/ci-cd.yml"
check_dir "cypress/e2e"
check_dir "cypress/support"

echo ""
echo "🔧 Vérification de la configuration Python..."

# Vérifier Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓${NC} Python installé: $PYTHON_VERSION"
else
    echo -e "${RED}✗${NC} Python n'est pas installé"
    exit 1
fi

# Vérifier pip
if python3 -m pip --version > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} pip installé"
else
    echo -e "${RED}✗${NC} pip n'est pas installé"
    exit 1
fi

echo ""
echo "📦 Vérification de Node.js..."

# Vérifier Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓${NC} Node.js installé: $NODE_VERSION"
else
    echo -e "${YELLOW}⚠${NC} Node.js n'est pas installé (requis pour tests E2E)"
fi

# Vérifier npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓${NC} npm installé: $NPM_VERSION"
else
    echo -e "${YELLOW}⚠${NC} npm n'est pas installé (requis pour tests E2E)"
fi

echo ""
echo "✅ Vérification complète!"
echo ""
echo "Prochaines étapes:"
echo "1. Configurez les secrets GitHub:"
echo "   - DOCKER_HUB_USERNAME"
echo "   - DOCKER_HUB_TOKEN"
echo ""
echo "2. Testez localement:"
echo "   pip install -r requirements.txt"
echo "   python app.py"
echo ""
echo "3. Exécutez les tests:"
echo "   pytest                  # Tests unitaires"
echo "   npm run test:e2e        # Tests E2E"
echo ""
echo "4. Poussez sur main:"
echo "   git push origin main"
