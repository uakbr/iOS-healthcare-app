import React, { useEffect, useState } from 'react';
import { Grid, Paper, Typography } from '@material-ui/core';
import { HealthDataChart } from './HealthDataChart';
import { RecommendationsList } from './RecommendationsList';
import { getHealthData, getRecommendations } from '../services/api';

interface HealthData {
  type: string;
  value: number;
  timestamp: string;
}

interface DashboardProps {}

export const Dashboard: React.FC<DashboardProps> = () => {
  const [healthData, setHealthData] = useState<HealthData[]>([]);
  const [recommendations, setRecommendations] = useState<string[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [healthResponse, recommendationsResponse] = await Promise.all([
          getHealthData(),
          getRecommendations()
        ]);
        setHealthData(healthResponse.data);
        setRecommendations(recommendationsResponse.data);
      } catch (err) {
        setError('Failed to fetch data');
        console.error('Error fetching data:', err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) {
    return (
      <Grid container justifyContent="center">
        <Typography>Loading...</Typography>
      </Grid>
    );
  }

  if (error) {
    return (
      <Grid container justifyContent="center">
        <Typography color="error">{error}</Typography>
      </Grid>
    );
  }

  return (
    <Grid container spacing={3}>
      <Grid item xs={12}>
        <Typography variant="h4">Your Health Dashboard</Typography>
      </Grid>
      <Grid item xs={12} md={8}>
        <Paper>
          <HealthDataChart data={healthData} />
        </Paper>
      </Grid>
      <Grid item xs={12} md={4}>
        <Paper>
          <RecommendationsList recommendations={recommendations} />
        </Paper>
      </Grid>
    </Grid>
  );
}; 