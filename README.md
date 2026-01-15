# Flask Application

Application web simple en Flask avec Docker.

## Fonctionnalités

- **Endpoint `/`** : Page d'accueil avec informations basiques
- **Endpoint `/health`** : Vérification de la santé de l'application (pour healthchecks)
- **Endpoint `/api/info`** : Informations sur l'application

## Utilisation Locale

### Prérequis

- Python 3.12+
- pip

### Installation et lancement

```bash
# Installer les dépendances
pip install -r requirements.txt

# Lancer l'application
python app.py
```

L'application est accessible sur `http://localhost:8080`

### Tester les endpoints

```bash
# Page d'accueil
curl http://localhost:8080/

# Health check
curl http://localhost:8080/health

# Informations API
curl http://localhost:8080/api/info
```

## Utilisation avec Docker

### Build et lancement avec Docker

```bash
# Construire l'image
docker build -t flask-app .

# Lancer le conteneur
docker run -p 8080:8080 flask-app
```

### Utilisation avec Docker Compose

```bash
# Démarrer l'application
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter l'application
docker-compose down
```

## Variables d'environnement

- `PORT` : Port sur lequel l'application écoute (par défaut : 8080)
- `ENVIRONMENT` : Environnement d'exécution (development/production)

## Tests

### Tests Unitaires (pytest)

```bash
# Lancer les tests unitaires
pytest

# Avec couverture
pytest --cov=app
```

### Tests E2E (Cypress)

**Prérequis :** L'application Flask doit être en cours d'exécution sur `http://localhost:8080`

#### Installation des dépendances

```bash
npm install
```

#### Lancer les tests en mode CI (mode headless)

```bash
npm run test:e2e
```

Cette commande unique lance tous les tests E2E en mode headless et convient pour CI/CD.

#### Lancer les tests en mode interactif

```bash
npm run cypress:open
```

#### Tests E2E inclus

Les tests couvrent :
1. **Disponibilité de l'application** : Vérification que l'app répond sur tous les endpoints
2. **Health Check** : Endpoint `/health` fonctionnel et rapide
3. **API Info** : Endpoint `/api/info` retournant les informations d'application
4. **Parcours utilisateur réel** : Simulation d'un flux complet
5. **Validation des réponses** : Vérification du format JSON
6. **Navigation navigateur** : Tests via le navigateur

**Total : 11 tests E2E** incluant :
- ✅ Tests de disponibilité
- ✅ Tests fonctionnels des endpoints
- ✅ Tests de performance (< 1s)
- ✅ Validation JSON
- ✅ Parcours utilisateur réel

## Architecture Docker

Le Dockerfile utilise une approche multi-stage :
- **Stage 1 (Builder)** : Installe les dépendances Python
- **Stage 2 (Runtime)** : Image minimale contenant uniquement ce qui est nécessaire

Avantages :
- Image finale plus légère
- Meilleure sécurité (utilisateur non-root)
- Healthcheck intégré dans docker-compose

## CI/CD Pipeline - GitHub Actions

Un workflow GitHub Actions complet est configuré pour automatiser les tests et le déploiement.

### 📋 Configuration initiale

1. Créez un fork ou clone du repository
2. Configurez les secrets GitHub (voir [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)) :
   - `DOCKER_HUB_USERNAME`
   - `DOCKER_HUB_TOKEN`
3. Pushez vers la branche `main` pour déclencher le workflow

### 🔄 Workflow automatisé

Le workflow `ci-cd.yml` exécute **3 jobs en parallèle/séquence** :

#### Job 1️⃣ : Unit Tests
- ✅ Install Python & dependencies
- ✅ Run pytest with coverage
- ✅ Upload coverage reports

#### Job 2️⃣ : E2E Tests  
- ✅ Start Flask application
- ✅ Install Node.js & Cypress
- ✅ Run E2E tests against live app
- ✅ Upload screenshots on failure

#### Job 3️⃣ : Build & Push Docker Hub
- ⏸️ **Dépend de :** Job 1 ✅ AND Job 2 ✅
- ✅ Build Docker image (multi-stage)
- ✅ Tag image (latest, branch, SHA)
- ✅ Push to Docker Hub
- ⏹️ **N'exécute que si les 2 premiers jobs réussissent**

#### Job 4️⃣ : Deploy to Azure VM

- ⏸️ **Dépend de :** Job 3 ✅
- ✅ Connexion SSH à la VM Azure
- ✅ Pull image depuis Docker Hub
- ✅ Redémarrage du conteneur (idempotent)
- ✅ Vérification que l'application répond
- ⏹️ **N'exécute que si Job 3 réussit**

**Note:** Nécessite 3 secrets GitHub configurés:
- `AZURE_VM_HOST` - IP ou hostname
- `AZURE_VM_USERNAME` - Utilisateur SSH
- `AZURE_VM_SSH_KEY` - Clé privée SSH

### 📊 Voir les résultats

1. Allez dans l'onglet **Actions** du repository
2. Cliquez sur le workflow `CI/CD Pipeline`
3. Consultez les logs détaillés de chaque job

### 📚 Documentation

- [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md) - Configuration des secrets
- [AZURE_DEPLOYMENT_SETUP.md](AZURE_DEPLOYMENT_SETUP.md) - Configuration Azure VM ⭐ NOUVEAU
- [AZURE_DEPLOYMENT.md](AZURE_DEPLOYMENT.md) - Guide du déploiement ⭐ NOUVEAU
- [WORKFLOW_GUIDE.md](WORKFLOW_GUIDE.md) - Guide détaillé du workflow

## Repository Structure

```
.
├── app.py                              # Application Flask
├── requirements.txt                    # Dépendances Python
├── Dockerfile                          # Configuration Docker
├── docker-compose.yml                  # Orchestration Docker
├── package.json                        # Dependencies npm
├── cypress.config.js                   # Configuration Cypress
├── pytest.ini                          # Configuration pytest
├── test_app.py                         # Tests unitaires (17 tests)
├── cypress/
│   └── e2e/
│       └── app.cy.js                   # Tests E2E (11 tests)
├── .github/
│   └── workflows/
│       └── ci-cd.yml                   # GitHub Actions workflow
├── GITHUB_ACTIONS_SETUP.md             # Setup secrets
├── AZURE_DEPLOYMENT_SETUP.md           # Setup Azure VM ⭐
├── AZURE_DEPLOYMENT.md                 # Guide déploiement ⭐
└── WORKFLOW_GUIDE.md                   # Workflow documentation
```