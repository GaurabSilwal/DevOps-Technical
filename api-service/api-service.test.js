const request = require('supertest');

// Mock the database pool
jest.mock('pg', () => ({
  Pool: jest.fn(() => ({
    query: jest.fn((sql) => {
      if (sql.includes('COUNT')) {
        return Promise.resolve({ rows: [{ count: '0' }] });
      }
      return Promise.resolve({ rows: [] });
    })
  }))
}));

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
      .expect(200)
      .expect('Content-Type', /json/);
    
    expect(response.body.users).toEqual([]);
    expect(response.body.pagination).toBeDefined();
  });

  afterAll((done) => {
    done();
  });
});