import React, { useEffect, useState } from 'react';
import { Grid, Paper, Typography, Box, makeStyles } from '@material-ui/core';
import { HealthDataChart } from './HealthDataChart';
import { HealthInsights } from './HealthInsights';
import { RecommendationsList } from './RecommendationsList';
import { getHealthData, getHealthInsights, getRecommendations } from '../services/api';
import { LoadingState } from './LoadingState';
import { ErrorState } from './ErrorState';

const useStyles = makeStyles((theme) => ({
  root: {
    padding: theme.spacing(3),
    maxWidth: 1200,
    margin: '0 auto',
  },
  header: {
    marginBottom: theme.spacing(4),
  },
  title: {
    fontWeight: 600,
    color: theme.palette.text.primary,
  },
  subtitle: {
    color: theme.palette.text.secondary,
    marginTop: theme.spacing(1),
  },
  section: {
    marginBottom: theme.spacing(4),
  },
  paper: {
    padding: theme.spacing(3),
    height: '100%',
    background: theme.palette.background.paper,
    backdropFilter: 'blur(20px)',
    border: '1px solid rgba(255, 255, 255, 0.1)',
  },
}));

export const Dashboard: React.FC = () => {
  const classes = useStyles();
  const [data, setData] = useState({
    healthData: [],
    insights: [],
    recommendations: [],
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [healthData, insights, recommendations] = await Promise.all([
          getHealthData(),
          getHealthInsights(),
          getRecommendations(),
        ]);
        
        setData({
          healthData: healthData.data,
          insights: insights.data,
          recommendations: recommendations.data,
        });
      } catch (err) {
        setError('Unable to load your health data');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) return <LoadingState />;
  if (error) return <ErrorState message={error} />;

  return (
    <Box className={classes.root}>
      <div className={classes.header}>
        <Typography variant="h1" className={classes.title}>
          Health Dashboard
        </Typography>
        <Typography variant="body1" className={classes.subtitle}>
          Your personal health insights and recommendations
        </Typography>
      </div>

      <Grid container spacing={3}>
        <Grid item xs={12} className={classes.section}>
          <HealthInsights insights={data.insights} />
        </Grid>

        <Grid item xs={12} md={8}>
          <Paper className={classes.paper}>
            <Typography variant="h3" gutterBottom>
              Health Trends
            </Typography>
            <HealthDataChart data={data.healthData} />
          </Paper>
        </Grid>

        <Grid item xs={12} md={4}>
          <Paper className={classes.paper}>
            <Typography variant="h3" gutterBottom>
              Recommendations
            </Typography>
            <RecommendationsList recommendations={data.recommendations} />
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
}; 