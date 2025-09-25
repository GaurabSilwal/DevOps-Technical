import React, { useState, useEffect, useCallback, useMemo } from 'react';
import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || '';

// Create axios instance with optimizations
const api = axios.create({
  baseURL: API_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

function App() {
  const [users, setUsers] = useState([]);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [pagination, setPagination] = useState({ page: 1, total: 0, pages: 0 });

  const fetchUsers = useCallback(async (page = 1) => {
    setLoading(true);
    setError('');
    try {
      const response = await api.get(`/api/users?page=${page}&limit=10`);
      setUsers(response.data.users || response.data);
      if (response.data.pagination) {
        setPagination(response.data.pagination);
      }
    } catch (error) {
      setError('Failed to fetch users. Please try again.');
      console.error('Error fetching users:', error);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  const addUser = useCallback(async (e) => {
    e.preventDefault();
    if (!name.trim() || !email.trim()) {
      setError('Please fill in all fields');
      return;
    }
    
    setLoading(true);
    setError('');
    try {
      await api.post('/api/users', { name: name.trim(), email: email.trim() });
      setName('');
      setEmail('');
      fetchUsers(pagination.page);
    } catch (error) {
      if (error.response?.status === 409) {
        setError('User with this email already exists');
      } else {
        setError('Failed to add user. Please try again.');
      }
      console.error('Error adding user:', error);
    } finally {
      setLoading(false);
    }
  }, [name, email, fetchUsers, pagination.page]);

  const handlePageChange = useCallback((newPage) => {
    fetchUsers(newPage);
  }, [fetchUsers]);

  const userList = useMemo(() => {
    return users.map((user) => (
      <li key={user.id} style={{ padding: '8px', borderBottom: '1px solid #eee' }}>
        <strong>{user.name}</strong> - {user.email}
        {user.created_at && (
          <small style={{ color: '#666', marginLeft: '10px' }}>
            {new Date(user.created_at).toLocaleDateString()}
          </small>
        )}
      </li>
    ));
  }, [users]);

  return (
    <div style={{ padding: '20px', maxWidth: '800px', margin: '0 auto' }}>
      <h1 style={{ color: '#333', marginBottom: '20px' }}>Microservices App</h1>
      
      {error && (
        <div style={{ 
          background: '#fee', 
          color: '#c33', 
          padding: '10px', 
          borderRadius: '4px', 
          marginBottom: '20px' 
        }}>
          {error}
        </div>
      )}
      
      <form onSubmit={addUser} style={{ marginBottom: '30px' }}>
        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
          <input
            type="text"
            placeholder="Name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            disabled={loading}
            style={{ 
              padding: '10px', 
              border: '1px solid #ddd', 
              borderRadius: '4px',
              flex: '1',
              minWidth: '200px'
            }}
            required
          />
          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            disabled={loading}
            style={{ 
              padding: '10px', 
              border: '1px solid #ddd', 
              borderRadius: '4px',
              flex: '1',
              minWidth: '200px'
            }}
            required
          />
          <button 
            type="submit" 
            disabled={loading}
            style={{ 
              padding: '10px 20px', 
              background: loading ? '#ccc' : '#007bff', 
              color: 'white', 
              border: 'none', 
              borderRadius: '4px',
              cursor: loading ? 'not-allowed' : 'pointer'
            }}
          >
            {loading ? 'Adding...' : 'Add User'}
          </button>
        </div>
      </form>

      <h2 style={{ color: '#333' }}>Users</h2>
      {loading && users.length === 0 ? (
        <p>Loading users...</p>
      ) : (
        <>
          <ul style={{ listStyle: 'none', padding: 0 }}>
            {userList}
          </ul>
          
          {pagination.pages > 1 && (
            <div style={{ marginTop: '20px', textAlign: 'center' }}>
              {Array.from({ length: pagination.pages }, (_, i) => i + 1).map(page => (
                <button
                  key={page}
                  onClick={() => handlePageChange(page)}
                  disabled={loading || page === pagination.page}
                  style={{
                    margin: '0 5px',
                    padding: '5px 10px',
                    background: page === pagination.page ? '#007bff' : '#f8f9fa',
                    color: page === pagination.page ? 'white' : '#333',
                    border: '1px solid #ddd',
                    borderRadius: '4px',
                    cursor: loading || page === pagination.page ? 'not-allowed' : 'pointer'
                  }}
                >
                  {page}
                </button>
              ))}
            </div>
          )}
        </>
      )}
    </div>
  );
}

export default App;