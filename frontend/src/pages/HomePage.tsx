import { Link } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

export const HomePage: React.FC = () => {
  const { isAuthenticated, user } = useAuth();

  return (
    <div className="page">
      <div className="container">
        <h1>Bienvenue</h1>
        <p className="subtitle">Template Fullstack Java / React</p>

        {isAuthenticated ? (
          <div className="welcome-section">
            <p>
              Bonjour <strong>{user?.firstName} {user?.lastName}</strong> !
            </p>
            <Link to="/dashboard" className="btn btn-primary">
              Accéder au tableau de bord
            </Link>
          </div>
        ) : (
          <div className="auth-links">
            <p>Connectez-vous ou créez un compte pour commencer.</p>
            <div className="btn-group">
              <Link to="/login" className="btn btn-primary">
                Se connecter
              </Link>
              <Link to="/register" className="btn btn-secondary">
                Créer un compte
              </Link>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

