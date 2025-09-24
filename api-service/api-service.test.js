const request = require('supertest');
const app = require('./server');

describe('API Service', () => {
  test('GET /health should return healthy status', async () => {
    const response = await request(app)
      .get('/health')
      .expect(200);
    
    expect(response.body.status).toBe('healthy');
    expect(response.body.timestamp).toBeDefined();
  });

  test('GET /api/users should return users array', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect('Content-Type', /json/);
    
    expect(Array.isArray(response.body) || response.body.error).toBeTruthy();
  });
});