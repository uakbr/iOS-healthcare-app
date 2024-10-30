import React from 'react';
import { Box, Typography, makeStyles } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  root: {
    padding: theme.spacing(3),
    textAlign: 'center',
  },
  message: {
    color: theme.palette.error.main,
  },
}));

interface Props {
  message: string;
}

export const ErrorState: React.FC<Props> = ({ message }) => {
  const classes = useStyles();

  return (
    <Box className={classes.root}>
      <Typography variant="h6" className={classes.message}>
        {message}
      </Typography>
    </Box>
  );
}; 