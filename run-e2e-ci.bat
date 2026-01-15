@echo off
REM Script pour lancer les tests E2E en CI/CD (Windows)
REM Usage: run-e2e-ci.bat [base_url]

setlocal enabledelayedexpansion

set BASE_URL=%1
if "%BASE_URL%"=="" (
    set BASE_URL=http://localhost:8080
)

echo ==========================================
echo Cypress E2E Tests - CI/CD Mode
echo ==========================================
echo Base URL: %BASE_URL%
echo.

REM Vérifier si Node.js est installé
where node >nul 2>nul
if errorlevel 1 (
    echo ❌ Node.js n'est pas installé
    exit /b 1
)

REM Vérifier si npm est installé
where npm >nul 2>nul
if errorlevel 1 (
    echo ❌ npm n'est pas installé
    exit /b 1
)

REM Installer les dépendances si nécessaire
if not exist "node_modules" (
    echo 📦 Installation des dépendances...
    call npm install
)

REM Lancer les tests en mode headless
echo 🧪 Lancement des tests E2E...
setlocal
set BASE_URL=%BASE_URL%
call npm run test:e2e
endlocal

if errorlevel 1 (
    echo.
    echo ❌ Tests E2E échoués!
    exit /b 1
)

echo.
echo ✅ Tests E2E terminés avec succès!
