import React from 'react';
import { Box, CircularProgress, Typography, makeStyles } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  root: {
    height: '100vh',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    background: theme.palette.background.default,
  },
  progress: {
    color: theme.palette.primary.main,
    marginBottom: theme.spacing(2),
  },
  text: {
    color: theme.palette.text.secondary,
  },
}));

export const LoadingState: React.FC = () => {
  const classes = useStyles();

  return (
    <Box className={classes.root}>
      <CircularProgress className={classes.progress} size={40} thickness={2} />
      <Typography variant="body1" className={classes.text}>
        Loading your health data...
      </Typography>
    </Box>
  );
}; 