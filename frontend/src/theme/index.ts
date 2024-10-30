import { createTheme } from '@material-ui/core/styles';

export const theme = createTheme({
  palette: {
    primary: {
      main: '#000000',
      light: '#333333',
      dark: '#000000',
    },
    secondary: {
      main: '#007AFF',
      light: '#5856D6',
      dark: '#0055FF',
    },
    background: {
      default: '#FFFFFF',
      paper: '#F5F5F7',
    },
    text: {
      primary: '#1D1D1F',
      secondary: '#86868B',
    },
  },
  typography: {
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    h1: {
      fontSize: '2.5rem',
      fontWeight: 600,
      letterSpacing: '-0.015em',
    },
    h2: {
      fontSize: '2rem',
      fontWeight: 600,
      letterSpacing: '-0.01em',
    },
    h3: {
      fontSize: '1.75rem',
      fontWeight: 500,
      letterSpacing: '-0.005em',
    },
    body1: {
      fontSize: '1rem',
      letterSpacing: '-0.003em',
    },
  },
  shape: {
    borderRadius: 12,
  },
  overrides: {
    MuiPaper: {
      rounded: {
        borderRadius: 12,
      },
      elevation1: {
        boxShadow: '0 0 20px rgba(0, 0, 0, 0.05)',
      },
    },
    MuiButton: {
      root: {
        textTransform: 'none',
        padding: '10px 24px',
        borderRadius: 8,
      },
      contained: {
        boxShadow: 'none',
        '&:hover': {
          boxShadow: 'none',
        },
      },
    },
  },
}); 