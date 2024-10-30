import React from 'react';
import { Box, Grid, Typography, makeStyles } from '@material-ui/core';
import { InsightCard } from './InsightCard';

const useStyles = makeStyles((theme) => ({
  root: {
    marginBottom: theme.spacing(4),
  },
  insightsGrid: {
    marginTop: theme.spacing(2),
  },
  sectionTitle: {
    fontWeight: 500,
    marginBottom: theme.spacing(1),
  },
}));

interface InsightData {
  type: string;
  value: number;
  target: number;
  unit: string;
  trend: 'up' | 'down' | 'stable';
  status: 'good' | 'warning' | 'alert';
}

interface Props {
  insights: InsightData[];
}

export const HealthInsights: React.FC<Props> = ({ insights }) => {
  const classes = useStyles();

  return (
    <Box className={classes.root}>
      <Typography variant="h2" className={classes.sectionTitle}>
        Today's Insights
      </Typography>
      <Grid container spacing={3} className={classes.insightsGrid}>
        {insights.map((insight) => (
          <Grid item xs={12} sm={6} md={3} key={insight.type}>
            <InsightCard insight={insight} />
          </Grid>
        ))}
      </Grid>
    </Box>
  );
}; 