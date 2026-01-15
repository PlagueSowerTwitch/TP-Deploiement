describe('Flask Application - E2E Tests', () => {
  // Test 1: Vérifier la disponibilité de l'application
  describe('Application Availability', () => {
    it('should verify application is available and responding', () => {
      // Vérifier que le root endpoint répond avec le bon status
      cy.request({
        method: 'GET',
        url: '/',
        failOnStatusCode: true,
      }).then((response) => {
        expect(response.status).to.equal(200);
        expect(response.body).to.have.property('message');
      });
    });

    it('should return 200 status for root endpoint', () => {
      cy.request({
        method: 'GET',
        url: '/',
        failOnStatusCode: true,
      }).then((response) => {
        expect(response.status).to.equal(200);
      });
    });
  });

  // Test 2: Tester la fonctionnalité /health
  describe('Health Check Endpoint', () => {
    it('should be accessible and return healthy status', () => {
      cy.request({
        method: 'GET',
        url: '/health',
        failOnStatusCode: true,
      }).then((response) => {
        expect(response.status).to.equal(200);
        expect(response.body).to.have.property('status', 'healthy');
        expect(response.body).to.have.property('service', 'Flask App');
      });
    });

    it('should respond quickly (less than 1 second)', () => {
      cy.request('/health').then((response) => {
        expect(response.duration).to.be.lessThan(1000);
      });
    });
  });

  // Test 3: Tester une fonctionnalité supplémentaire (endpoint /api/info)
  describe('API Info Endpoint', () => {
    it('should return application information', () => {
      cy.request({
        method: 'GET',
        url: '/api/info',
        failOnStatusCode: true,
      }).then((response) => {
        expect(response.status).to.equal(200);
        expect(response.body).to.have.property('app_name', 'Flask Application');
        expect(response.body).to.have.property('port');
        expect(response.body).to.have.property('environment');
      });
    });

    it('should contain valid port information', () => {
      cy.request('/api/info').then((response) => {
        expect(response.body.port).to.exist;
      });
    });
  });

  // Test 4: Parcours utilisateur réel
  describe('User Journey - Real Application Flow', () => {
    it('should complete a full application flow', () => {
      // 1. Vérifier la disponibilité
      cy.request('/').then((response) => {
        expect(response.status).to.equal(200);
        expect(response.body).to.have.property('message');
      });

      // 2. Vérifier le health check
      cy.request('/health').then((response) => {
        expect(response.status).to.equal(200);
        expect(response.body.status).to.equal('healthy');
      });

      // 3. Récupérer les informations de l'application
      cy.request('/api/info').then((response) => {
        expect(response.status).to.equal(200);
        expect(response.body.app_name).to.exist;
      });

      // 4. Vérifier que tous les endpoints répondent
      cy.request('/').then((response) => {
        expect(response.status).to.equal(200);
      });
    });
  });

  // Test 5: Validation des réponses JSON
  describe('Response Format Validation', () => {
    it('all endpoints should return valid JSON', () => {
      cy.request('/').then((response) => {
        expect(response.headers['content-type']).to.include('application/json');
      });

      cy.request('/health').then((response) => {
        expect(response.headers['content-type']).to.include('application/json');
      });

      cy.request('/api/info').then((response) => {
        expect(response.headers['content-type']).to.include('application/json');
      });
    });
  });
  //Vérifier les propriétés complètes des réponses
  describe('Response Properties Validation', () => {
    it('should have correct properties in root endpoint response', () => {
      cy.request('/').then((response) => {
        expect(response.body).to.have.property('message');
        expect(response.body).to.have.property('version');
        expect(response.body.message).to.be.a('string');
        expect(response.body.version).to.be.a('string');
      });
    });

    it('should have correct properties in health endpoint response', () => {
      cy.request('/health').then((response) => {
        expect(response.body).to.have.property('status', 'healthy');
        expect(response.body).to.have.property('service', 'Flask App');
      });
    });

    it('should have correct properties in info endpoint response', () => {
      cy.request('/api/info').then((response) => {
        expect(response.body).to.have.property('app_name', 'Flask Application');
        expect(response.body).to.have.property('port');
        expect(response.body).to.have.property('environment');
      });
    });
  });
});
