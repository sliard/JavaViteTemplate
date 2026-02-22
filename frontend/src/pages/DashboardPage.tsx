import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';

export const DashboardPage: React.FC = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <div className="page">
      <div className="container">
        <header className="dashboard-header">
          <h1>Tableau de bord</h1>
          <button onClick={handleLogout} className="btn btn-secondary">
            Se déconnecter
          </button>
        </header>

        <div className="card">
          <h2>Mon profil</h2>
          <div className="profile-info">
            <p>
              <strong>Nom :</strong> {user?.firstName} {user?.lastName}
            </p>
            <p>
              <strong>Email :</strong> {user?.email}
            </p>
            <p>
              <strong>Rôle :</strong> {user?.role}
            </p>
          </div>
        </div>

        <div className="card">
          <h2>Bienvenue !</h2>
          <p>
            Vous êtes connecté. Ce template est prêt à être personnalisé pour
            votre projet.
          </p>
        </div>
      </div>
    </div>
  );
};

