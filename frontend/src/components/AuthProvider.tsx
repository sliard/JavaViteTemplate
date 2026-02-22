import {
  useState,
  useEffect,
  useCallback,
  type ReactNode,
} from 'react';
import type { User, LoginRequest, RegisterRequest } from '../types/auth';
import { authService } from '../services/authService';
import { AuthContext } from '../hooks/AuthContext';

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  const storeTokens = (accessToken: string, refreshToken: string) => {
    localStorage.setItem('accessToken', accessToken);
    localStorage.setItem('refreshToken', refreshToken);
  };

  const clearTokens = () => {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  };

  const fetchUser = useCallback(async () => {
    try {
      const token = localStorage.getItem('accessToken');
      if (!token) {
        setLoading(false);
        return;
      }
      const currentUser = await authService.getCurrentUser();
      setUser(currentUser);
    } catch {
      // Token invalide ou expiré, essayer le refresh
      try {
        const refreshToken = localStorage.getItem('refreshToken');
        if (refreshToken) {
          const response = await authService.refreshToken(refreshToken);
          storeTokens(response.accessToken, response.refreshToken);
          const currentUser = await authService.getCurrentUser();
          setUser(currentUser);
        }
      } catch {
        clearTokens();
        setUser(null);
      }
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchUser();
  }, [fetchUser]);

  const login = async (credentials: LoginRequest) => {
    const response = await authService.login(credentials);
    storeTokens(response.accessToken, response.refreshToken);
    const currentUser = await authService.getCurrentUser();
    setUser(currentUser);
  };

  const register = async (data: RegisterRequest) => {
    const response = await authService.register(data);
    storeTokens(response.accessToken, response.refreshToken);
    const currentUser = await authService.getCurrentUser();
    setUser(currentUser);
  };

  const logout = () => {
    authService.logout().catch(() => {});
    clearTokens();
    setUser(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        loading,
        login,
        register,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

