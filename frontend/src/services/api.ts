import axios from 'axios';

declare global {
    namespace NodeJS {
        interface ProcessEnv {
            REACT_APP_API_BASE_URL: string;
        }
    }
}

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:8000';

const api = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Enhanced Health Data
export const syncHealthKit = (data: any) => api.post('/health-data/sync', data);
export const getHealthData = (type?: string) => api.get(`/health-data${type ? `/${type}` : ''}`);
export const getEnvironmentalData = () => api.get('/health-data/environmental');
export const getMentalHealthData = () => api.get('/health-data/mental');
export const getSleepAnalysis = () => api.get('/health-data/sleep');
export const getActivityData = () => api.get('/health-data/activity');
export const getHealthInsights = () => api.get('/health-insights');
export const getRecommendations = () => api.get('/recommendations');

// Background Location
export const updateLocation = (location: any) => api.post('/location/update', location);
export const getLocationHistory = () => api.get('/location/history');

// Device Data
export const updateDeviceMetrics = (metrics: any) => api.post('/device-metrics', metrics);
export const getDeviceAnalytics = () => api.get('/device-metrics/analytics');

// Notifications
export const registerPushToken = (token: string) => api.post('/notifications/register', { token });
export const updateNotificationPreferences = (prefs: any) => 
    api.put('/notifications/preferences', prefs);