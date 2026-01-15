// Support file for Cypress E2E tests
Cypress.on('uncaught:exception', (err, runnable) => {
  return true;
});
