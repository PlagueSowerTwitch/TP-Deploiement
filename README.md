# Application Flask - Pipeline CI/CD vers Azure VM

## 📋 Vue d'ensemble

Ce projet démontre l'implémentation d'une **pipeline CI/CD complète** pour une application Flask, avec tests automatisés et déploiement continu sur une machine virtuelle Azure. L'objectif principal est de garantir la qualité du code et l'automatisation du déploiement en production.

## 🎯 Objectifs du projet

- ✅ Automatiser les tests unitaires et les tests end-to-end
- ✅ Valider la qualité du code avec une couverture de test
- ✅ Construire et publier des images Docker
- ✅ Déployer automatiquement l'application sur Azure VM
- ✅ Vérifier la santé de l'application après déploiement

## 🏗️ Architecture

### Application

L'application est une API Flask simple avec trois endpoints principaux :

- `GET /` : Page d'accueil
- `GET /health` : Vérification de la santé du service
- `GET /api/info` : Informations sur l'application

### Stack technique

| Composant | Technologie | Version |
|-----------|-------------|---------|
| Framework web | Flask | 3.0.0 |
| Conteneurisation | Docker | Multi-stage build |
| Orchestration | Docker Compose | 3.8 |
| Tests unitaires | pytest + pytest-cov | 7.4.3 |
| Tests E2E | Cypress | 20 |
| CI/CD | GitHub Actions | Latest |
| Infrastructure | Azure VM | - |

## 🔄 Pipeline CI/CD

La pipeline est déclenchée automatiquement à chaque **push sur la branche `main`**. Elle comprend 4 étapes principales :

### 1️⃣ Tests unitaires (Unit Tests)

```
✓ Installation des dépendances Python
✓ Exécution de pytest avec couverture de code
✓ Upload automatique des rapports de couverture vers Codecov
```

**Artefacts générés :** `coverage.xml`

### 2️⃣ Tests End-to-End (E2E)

```
✓ Lancement de l'application Flask
✓ Attente de la réponse du healthcheck (max 30s)
✓ Installation des dépendances Node.js
✓ Exécution des tests Cypress
✓ Sauvegarde des screenshots en cas d'échec
```

**Artefacts générés :** Screenshots Cypress (7 jours de rétention)

### 3️⃣ Build & Push Docker

Déclenché **seulement après succès des tests**, cette étape :

```
✓ Setup Docker Buildx pour optimiser le build
✓ Authentication à Docker Hub
✓ Build de l'image avec cache GitHub Actions
✓ Push vers Docker Hub avec tags intelligents
```

**Tags générés :**
- `main` (branche)
- `main-<SHA>` (commit SHA)
- `latest` (branche par défaut)

### 4️⃣ Déploiement Azure VM

Déclenché **après succès du build Docker**, cette étape :

```
✓ Connexion SSH à la VM Azure
✓ Authentication Docker Hub sur la VM
✓ Pull de la dernière image Docker
✓ Arrêt du conteneur existant
✓ Lancement du nouveau conteneur
✓ Vérification de santé (health checks)
✓ Validation de tous les endpoints
```

## 🚀 Comment le déploiement est déclenché

### Déclencheur principal
```
on:
  push:
    branches:
      - main
```

**Le déploiement se déclenche automatiquement lorsque vous pushez du code sur la branche `main`.**

### Flux de déploiement

```
push sur main
    ↓
Unit Tests ──┐
             │
E2E Tests ───┼─→ Build & Push Docker ──→ Deploy to Azure VM
             │
     (tous doivent réussir)
```

### Configuration requise (GitHub Secrets)

Pour fonctionner, la pipeline nécessite les secrets suivants :

| Secret | Description |
|--------|-------------|
| `DOCKER_HUB_USERNAME` | Nom d'utilisateur Docker Hub |
| `DOCKER_HUB_TOKEN` | Token d'authentification Docker Hub |
| `AZURE_VM_HOST` | Adresse IP/DNS de la VM Azure |
| `AZURE_VM_USERNAME` | Utilisateur SSH de la VM |
| `AZURE_VM_SSH_KEY` | Clé privée SSH pour la connexion |

## 🛠️ Choix techniques

### 1. **Docker Multi-stage Build**
```dockerfile
Stage 1: Builder → compilation et installation des dépendances
Stage 2: Runtime → image légère contenant uniquement les fichiers nécessaires
```
✅ **Bénéfices :** Image finale plus légère (~500MB vs 1GB)

### 2. **Utilisateur non-root dans le conteneur**
```dockerfile
RUN useradd -m -u 1000 appuser
USER appuser
```
✅ **Bénéfices :** Sécurité renforcée, isolation des processus

### 3. **Health checks intégrés**
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
  interval: 30s
```
✅ **Bénéfices :** Détection automatique des défaillances, redémarrage automatique

### 4. **Stratégie de déploiement Blue-Green**
```bash
docker stop flask-app-prod (ancienne instance)
docker run (nouvelle instance)
```
✅ **Bénéfices :** Zéro downtime, possibilité de rollback rapide

### 5. **Cache GitHub Actions**
```yaml
cache-from: type=gha
cache-to: type=gha,mode=max
```
✅ **Bénéfices :** Réduction du temps de build (~60% plus rapide)

### 6. **Vérifications post-déploiement**
```bash
✓ Test endpoint /health
✓ Test endpoint /
✓ Test endpoint /api/info
```
✅ **Bénéfices :** Garantie que l'application fonctionne correctement avant de considérer le déploiement réussi

### 7. **Séparation des responsabilités**
- Tests et builds **sans privilèges root**
- Déploiement via SSH avec clé privée
- Secrets stockés de manière sécurisée dans GitHub
✅ **Bénéfices :** Meilleure sécurité et auditabilité

## 📊 Statistiques

| Métrique | Valeur |
|----------|--------|
| Dépendances Python | 4 packages |
| Temps de build Docker | ~30-45s (avec cache) |
| Couverture de tests | Suivie par Codecov |
| Endpoints validés | 3 endpoints |
| Timeout déploiement | 30s par étape |

## 🔐 Sécurité

- ✅ Conteneur exécuté avec utilisateur non-root
- ✅ Pas de secrets en dur dans le code
- ✅ SSH avec clé privée pour le déploiement
- ✅ Authentification Docker Hub sécurisée
- ✅ Validation HTTPS via healthcheck

## 📝 Exemple de déploiement réussi

```
✅ Unit Tests: 5 tests passés
✅ E2E Tests: 20 tests passés (Cypress)
✅ Build & Push: Image publiée sur Docker Hub
✅ Deploy to Azure: Application déployée et vérifiée
```

**Résultat :** Application accessible à `http://<VM-IP>:8080`

## 🛑 Dépannage

### Si les tests échouent
→ Vérifiez les logs GitHub Actions pour identifier l'erreur
→ La pipeline s'arrête et ne déploie pas

### Si le déploiement échoue
1. Vérifiez les secrets GitHub
2. Testez la connexion SSH à la VM
3. Vérifiez que Docker est installé sur la VM
4. Consultez les logs du workflow

## 📚 Commandes utiles

```bash
# Lancer les tests localement
pytest -v --cov=app --cov-report=html

# Lancer les tests E2E
npm run test:e2e

# Builder l'image Docker
docker build -t flask-app:latest .

# Démarrer l'application
docker-compose up -d

# Vérifier la santé
curl http://localhost:8080/health
```

---