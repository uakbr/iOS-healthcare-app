import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:8000';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const getHealthData = () => api.get('/health-data');
export const getRecommendations = () => api.get('/recommendations');
export const updateHealthData = (data: any) => api.post('/health-data', data);
export const uploadGeneticData = (data: any) => api.post('/genetic-data', data); 