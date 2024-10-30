import React from 'react';
import { List, ListItem, ListItemText } from '@material-ui/core';

interface Props {
  recommendations: string[];
}

export const RecommendationsList: React.FC<Props> = ({ recommendations }) => {
  return (
    <List>
      {recommendations.map((recommendation, index) => (
        <ListItem key={index}>
          <ListItemText primary={recommendation} />
        </ListItem>
      ))}
    </List>
  );
}; 