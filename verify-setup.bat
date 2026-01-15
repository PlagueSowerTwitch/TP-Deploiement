@echo off
REM Script de vérification locale avant push (Windows)
REM Vérifie que tout fonctionne avant de pousser sur main

setlocal enabledelayedexpansion

echo 🔍 Verification locale de la configuration CI/CD
echo ==================================================
echo.

REM Vérifier les fichiers essentiels
echo 📋 Verification des fichiers...

for %%f in (app.py requirements.txt Dockerfile docker-compose.yml package.json cypress.config.js pytest.ini test_app.py) do (
    if exist "%%f" (
        echo ✓ %%f existe
    ) else (
        echo ✗ %%f manquant
    )
)

if exist ".github\workflows\ci-cd.yml" (
    echo ✓ .github\workflows\ci-cd.yml existe
) else (
    echo ✗ .github\workflows\ci-cd.yml manquant
)

if exist "cypress\e2e" (
    echo ✓ cypress\e2e existe
) else (
    echo ✗ cypress\e2e manquant
)

echo.
echo 🔧 Verification de la configuration Python...

REM Vérifier Python
where python >nul 2>nul
if errorlevel 1 (
    echo ✗ Python n'est pas installe
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo ✓ Python installe: !PYTHON_VERSION!
)

REM Vérifier pip
python -m pip --version >nul 2>&1
if errorlevel 1 (
    echo ✗ pip n'est pas installe
    exit /b 1
) else (
    echo ✓ pip installe
)

echo.
echo 📦 Verification de Node.js...

REM Vérifier Node.js
where node >nul 2>nul
if errorlevel 1 (
    echo ⚠ Node.js n'est pas installe ^(requis pour tests E2E^)
) else (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo ✓ Node.js installe: !NODE_VERSION!
)

REM Vérifier npm
where npm >nul 2>nul
if errorlevel 1 (
    echo ⚠ npm n'est pas installe ^(requis pour tests E2E^)
) else (
    for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
    echo ✓ npm installe: !NPM_VERSION!
)

echo.
echo ✅ Verification complete!
echo.
echo Prochaines etapes:
echo 1. Configurez les secrets GitHub:
echo    - DOCKER_HUB_USERNAME
echo    - DOCKER_HUB_TOKEN
echo.
echo 2. Testez localement:
echo    pip install -r requirements.txt
echo    python app.py
echo.
echo 3. Executez les tests:
echo    pytest                  ^(Tests unitaires^)
echo    npm run test:e2e        ^(Tests E2E^)
echo.
echo 4. Poussez sur main:
echo    git push origin main
