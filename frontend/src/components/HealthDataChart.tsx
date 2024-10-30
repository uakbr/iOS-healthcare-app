import React from 'react';
import { Paper, Typography, useTheme } from '@material-ui/core';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { format } from 'date-fns';

interface HealthDataPoint {
  type: string;
  value: number;
  timestamp: string;
  metadata: {
    device: string;
    source: string;
    unit: string;
  };
}

interface Props {
  data: HealthDataPoint[];
  type: string;
}

export const HealthDataChart: React.FC<Props> = ({ data, type }) => {
  const theme = useTheme();

  const formatData = (data: HealthDataPoint[]) => {
    return data
      .filter(point => point.type === type)
      .map(point => ({
        ...point,
        time: format(new Date(point.timestamp), 'HH:mm'),
        date: format(new Date(point.timestamp), 'MM/dd')
      }));
  };

  return (
    <Paper style={{ padding: '20px', height: 300 }}>
      <Typography variant="h6" gutterBottom>
        {type.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')}
      </Typography>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={formatData(data)}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="time" />
          <YAxis />
          <Tooltip
            content={({ active, payload }) => {
              if (active && payload && payload.length) {
                const data = payload[0].payload;
                return (
                  <Paper style={{ padding: '10px' }}>
                    <Typography variant="body2">
                      {`${data.date} ${data.time}`}
                    </Typography>
                    <Typography variant="body2">
                      {`Value: ${data.value} ${data.metadata.unit}`}
                    </Typography>
                    <Typography variant="caption" color="textSecondary">
                      {`Source: ${data.metadata.source}`}
                    </Typography>
                  </Paper>
                );
              }
              return null;
            }}
          />
          <Line
            type="monotone"
            dataKey="value"
            stroke={theme.palette.primary.main}
            strokeWidth={2}
            dot={{ r: 4 }}
            activeDot={{ r: 8 }}
          />
        </LineChart>
      </ResponsiveContainer>
    </Paper>
  );
}; 