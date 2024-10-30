import React from 'react';
import { Paper } from '@material-ui/core';

interface Props {
  data: any[];
}

export const HealthDataChart: React.FC<Props> = ({ data }) => {
  return (
    <Paper style={{ padding: '20px' }}>
      <h3>Health Data Visualization</h3>
      {/* Add your chart implementation here */}
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </Paper>
  );
}; 