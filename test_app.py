import pytest
import json
from app import app


@pytest.fixture
def client():
    """Fixture pour créer un client de test Flask"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


class TestHomeEndpoint:
    """Tests pour l'endpoint de la page d'accueil"""

    def test_home_returns_200(self, client):
        """Test que la page d'accueil retourne un code 200"""
        response = client.get('/')
        assert response.status_code == 200

    def test_home_returns_json(self, client):
        """Test que la page d'accueil retourne du JSON"""
        response = client.get('/')
        assert response.content_type == 'application/json'

    def test_home_contains_message(self, client):
        """Test que la réponse contient un message"""
        response = client.get('/')
        data = json.loads(response.data)
        assert 'message' in data
        assert data['message'] == "Bienvenue sur l'application Flask"

    def test_home_contains_version(self, client):
        """Test que la réponse contient la version"""
        response = client.get('/')
        data = json.loads(response.data)
        assert 'version' in data
        assert data['version'] == "1.0"


class TestHealthEndpoint:
    """Tests pour l'endpoint de santé"""

    def test_health_returns_200(self, client):
        """Test que l'endpoint health retourne un code 200"""
        response = client.get('/health')
        assert response.status_code == 200

    def test_health_returns_json(self, client):
        """Test que l'endpoint health retourne du JSON"""
        response = client.get('/health')
        assert response.content_type == 'application/json'

    def test_health_status_is_healthy(self, client):
        """Test que le statut de santé est 'healthy'"""
        response = client.get('/health')
        data = json.loads(response.data)
        assert 'status' in data
        assert data['status'] == 'healthy'

    def test_health_contains_service_name(self, client):
        """Test que la réponse contient le nom du service"""
        response = client.get('/health')
        data = json.loads(response.data)
        assert 'service' in data
        assert data['service'] == 'Flask App'


class TestInfoEndpoint:
    """Tests pour l'endpoint d'informations API"""

    def test_info_returns_200(self, client):
        """Test que l'endpoint info retourne un code 200"""
        response = client.get('/api/info')
        assert response.status_code == 200

    def test_info_returns_json(self, client):
        """Test que l'endpoint info retourne du JSON"""
        response = client.get('/api/info')
        assert response.content_type == 'application/json'

    def test_info_contains_app_name(self, client):
        """Test que la réponse contient le nom de l'application"""
        response = client.get('/api/info')
        data = json.loads(response.data)
        assert 'app_name' in data
        assert data['app_name'] == 'Flask Application'

    def test_info_contains_port(self, client):
        """Test que la réponse contient le port"""
        response = client.get('/api/info')
        data = json.loads(response.data)
        assert 'port' in data

    def test_info_contains_environment(self, client):
        """Test que la réponse contient l'environnement"""
        response = client.get('/api/info')
        data = json.loads(response.data)
        assert 'environment' in data


class TestErrorHandling:
    """Tests pour la gestion des erreurs"""

    def test_404_for_unknown_route(self, client):
        """Test que une route inconnue retourne 404"""
        response = client.get('/unknown')
        assert response.status_code == 404

    def test_405_for_post_on_get_endpoint(self, client):
        """Test que POST sur une route GET retourne 405"""
        response = client.post('/health')
        assert response.status_code == 405


class TestIntegration:
    """Tests d'intégration"""

    def test_all_endpoints_are_accessible(self, client):
        """Test que tous les endpoints principaux sont accessibles"""
        endpoints = ['/', '/health', '/api/info']
        for endpoint in endpoints:
            response = client.get(endpoint)
            assert response.status_code == 200, f"Endpoint {endpoint} should be accessible"

    def test_all_endpoints_return_json(self, client):
        """Test que tous les endpoints retournent du JSON"""
        endpoints = ['/', '/health', '/api/info']
        for endpoint in endpoints:
            response = client.get(endpoint)
            assert response.content_type == 'application/json', \
                f"Endpoint {endpoint} should return JSON"
