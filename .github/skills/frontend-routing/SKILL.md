---
name: frontend-routing
description: Configure React Router with lazy loading and protected routes for React 19. Use this when asked to set up routing, navigation, or protected pages.
---

# React Router Configuration

Generate routing configuration following project conventions for React 19 with React Router 6.

## Required Dependencies

```json
{
  "dependencies": {
    "react-router-dom": "^6.22.0"
  }
}
```

## Basic Router Setup

### src/router/index.tsx

```typescript
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { lazy, Suspense } from 'react';
import { RootLayout } from '../layouts/RootLayout';
import { AuthLayout } from '../layouts/AuthLayout';
import { ProtectedRoute } from '../components/ProtectedRoute';
import { LoadingSpinner } from '../components/LoadingSpinner';
import { ErrorPage } from '../pages/ErrorPage';

// Lazy load pages
const HomePage = lazy(() => import('../pages/HomePage'));
const LoginPage = lazy(() => import('../pages/auth/LoginPage'));
const RegisterPage = lazy(() => import('../pages/auth/RegisterPage'));
const DashboardPage = lazy(() => import('../pages/DashboardPage'));
const ProductsPage = lazy(() => import('../pages/products/ProductsPage'));
const ProductDetailPage = lazy(() => import('../pages/products/ProductDetailPage'));
const ProductCreatePage = lazy(() => import('../pages/products/ProductCreatePage'));
const ProductEditPage = lazy(() => import('../pages/products/ProductEditPage'));
const ProfilePage = lazy(() => import('../pages/ProfilePage'));
const AdminPage = lazy(() => import('../pages/admin/AdminPage'));
const NotFoundPage = lazy(() => import('../pages/NotFoundPage'));

// Suspense wrapper
const withSuspense = (Component: React.LazyExoticComponent<React.FC>) => (
  <Suspense fallback={<LoadingSpinner />}>
    <Component />
  </Suspense>
);

export const router = createBrowserRouter([
  {
    path: '/',
    element: <RootLayout />,
    errorElement: <ErrorPage />,
    children: [
      // Public routes
      {
        index: true,
        element: withSuspense(HomePage),
      },
      {
        path: 'products',
        children: [
          {
            index: true,
            element: withSuspense(ProductsPage),
          },
          {
            path: ':id',
            element: withSuspense(ProductDetailPage),
          },
        ],
      },

      // Auth routes (redirect if already logged in)
      {
        element: <AuthLayout />,
        children: [
          {
            path: 'login',
            element: withSuspense(LoginPage),
          },
          {
            path: 'register',
            element: withSuspense(RegisterPage),
          },
        ],
      },

      // Protected routes (require authentication)
      {
        element: <ProtectedRoute />,
        children: [
          {
            path: 'dashboard',
            element: withSuspense(DashboardPage),
          },
          {
            path: 'profile',
            element: withSuspense(ProfilePage),
          },
          {
            path: 'products/new',
            element: withSuspense(ProductCreatePage),
          },
          {
            path: 'products/:id/edit',
            element: withSuspense(ProductEditPage),
          },
        ],
      },

      // Admin routes (require admin role)
      {
        element: <ProtectedRoute requiredRole="ADMIN" />,
        children: [
          {
            path: 'admin',
            element: withSuspense(AdminPage),
          },
        ],
      },

      // 404
      {
        path: '*',
        element: withSuspense(NotFoundPage),
      },
    ],
  },
]);

export const AppRouter: React.FC = () => {
  return <RouterProvider router={router} />;
};
```

---

## Layouts

### RootLayout

```typescript
// layouts/RootLayout.tsx
import { Outlet } from 'react-router-dom';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';

export const RootLayout: React.FC = () => {
  return (
    <div className="app-layout">
      <Header />
      <main className="main-content">
        <Outlet />
      </main>
      <Footer />
    </div>
  );
};
```

### AuthLayout (Redirects if already authenticated)

```typescript
// layouts/AuthLayout.tsx
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

export const AuthLayout: React.FC = () => {
  const { isAuthenticated, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return <LoadingSpinner />;
  }

  if (isAuthenticated) {
    // Redirect to the page they came from, or dashboard
    const from = location.state?.from?.pathname || '/dashboard';
    return <Navigate to={from} replace />;
  }

  return (
    <div className="auth-layout">
      <div className="auth-container">
        <Outlet />
      </div>
    </div>
  );
};
```

---

## Protected Route Component

```typescript
// components/ProtectedRoute.tsx
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import { LoadingSpinner } from './LoadingSpinner';

interface ProtectedRouteProps {
  requiredRole?: string;
  children?: React.ReactNode;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  requiredRole,
  children,
}) => {
  const { user, isAuthenticated, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return <LoadingSpinner />;
  }

  if (!isAuthenticated) {
    // Save the attempted URL for redirecting after login
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  if (requiredRole && user?.role !== requiredRole) {
    // User doesn't have required role
    return <Navigate to="/unauthorized" replace />;
  }

  return children ? <>{children}</> : <Outlet />;
};
```

---

## Navigation Components

### Navigation Links

```typescript
// components/NavLink.tsx
import { NavLink as RouterNavLink, NavLinkProps as RouterNavLinkProps } from 'react-router-dom';
import { clsx } from 'clsx';

interface NavLinkProps extends RouterNavLinkProps {
  children: React.ReactNode;
}

export const NavLink: React.FC<NavLinkProps> = ({ children, className, ...props }) => {
  return (
    <RouterNavLink
      className={({ isActive }) => clsx('nav-link', isActive && 'nav-link--active', className)}
      {...props}
    >
      {children}
    </RouterNavLink>
  );
};
```

### Header with Navigation

```typescript
// components/Header.tsx
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import { NavLink } from './NavLink';

export const Header: React.FC = () => {
  const { user, isAuthenticated, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <header className="header">
      <Link to="/" className="logo">
        MyApp
      </Link>

      <nav className="nav">
        <NavLink to="/">Accueil</NavLink>
        <NavLink to="/products">Produits</NavLink>

        {isAuthenticated ? (
          <>
            <NavLink to="/dashboard">Dashboard</NavLink>
            {user?.role === 'ADMIN' && <NavLink to="/admin">Admin</NavLink>}
            <NavLink to="/profile">{user?.firstName}</NavLink>
            <button onClick={handleLogout}>Déconnexion</button>
          </>
        ) : (
          <>
            <NavLink to="/login">Connexion</NavLink>
            <NavLink to="/register">Inscription</NavLink>
          </>
        )}
      </nav>
    </header>
  );
};
```

---

## Route Hooks

### useNavigateWithState

```typescript
// hooks/useNavigateWithState.ts
import { useNavigate, useLocation } from 'react-router-dom';

export const useNavigateWithState = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const navigateBack = () => {
    const from = location.state?.from?.pathname;
    navigate(from || -1);
  };

  const navigateTo = (path: string, state?: Record<string, unknown>) => {
    navigate(path, { state: { from: location, ...state } });
  };

  return { navigateBack, navigateTo };
};
```

### useRouteParams

```typescript
// hooks/useRouteParams.ts
import { useParams } from 'react-router-dom';

export const useProductParams = () => {
  const { id } = useParams<{ id: string }>();

  if (!id) {
    throw new Error('Product ID is required');
  }

  return { productId: id };
};
```

### useBreadcrumbs

```typescript
// hooks/useBreadcrumbs.ts
import { useLocation, useMatches } from 'react-router-dom';

interface Breadcrumb {
  path: string;
  label: string;
}

interface RouteHandle {
  breadcrumb?: string | ((params: Record<string, string>) => string);
}

export const useBreadcrumbs = (): Breadcrumb[] => {
  const matches = useMatches();

  return matches
    .filter((match) => (match.handle as RouteHandle)?.breadcrumb)
    .map((match) => {
      const handle = match.handle as RouteHandle;
      const label = typeof handle.breadcrumb === 'function'
        ? handle.breadcrumb(match.params as Record<string, string>)
        : handle.breadcrumb!;

      return {
        path: match.pathname,
        label,
      };
    });
};

// Router configuration with handles
{
  path: 'products',
  handle: { breadcrumb: 'Produits' },
  children: [
    {
      path: ':id',
      handle: { breadcrumb: (params) => `Produit ${params.id}` },
    },
  ],
}
```

---

## Page Components

### Page with Data Loading

```typescript
// pages/products/ProductDetailPage.tsx
import { useParams, Link } from 'react-router-dom';
import { useProduct } from '../../hooks/useProduct';
import { LoadingSpinner } from '../../components/LoadingSpinner';
import { ErrorMessage } from '../../components/ErrorMessage';

const ProductDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { product, loading, error } = useProduct(id!);

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message={error.message} />;
  if (!product) return <ErrorMessage message="Produit non trouvé" />;

  return (
    <div className="product-detail">
      <nav className="breadcrumb">
        <Link to="/">Accueil</Link>
        <span>/</span>
        <Link to="/products">Produits</Link>
        <span>/</span>
        <span>{product.name}</span>
      </nav>

      <h1>{product.name}</h1>
      <p className="price">{product.price} €</p>
      <p className="description">{product.description}</p>

      <Link to={`/products/${id}/edit`} className="btn">
        Modifier
      </Link>
    </div>
  );
};

export default ProductDetailPage;
```

### Page with Navigation Actions

```typescript
// pages/products/ProductCreatePage.tsx
import { useNavigate } from 'react-router-dom';
import { ProductForm } from '../../components/ProductForm';
import { useCreateProduct } from '../../hooks/useCreateProduct';

const ProductCreatePage: React.FC = () => {
  const navigate = useNavigate();
  const { createProduct, loading, error } = useCreateProduct({
    onSuccess: (product) => {
      navigate(`/products/${product.id}`, { 
        state: { message: 'Produit créé avec succès' } 
      });
    },
  });

  return (
    <div className="product-create">
      <h1>Nouveau produit</h1>
      
      {error && <ErrorMessage message={error.message} />}
      
      <ProductForm
        onSubmit={createProduct}
        onCancel={() => navigate(-1)}
        submitLabel="Créer le produit"
      />
    </div>
  );
};

export default ProductCreatePage;
```

---

## Error Handling

### Error Page

```typescript
// pages/ErrorPage.tsx
import { useRouteError, isRouteErrorResponse, Link } from 'react-router-dom';

export const ErrorPage: React.FC = () => {
  const error = useRouteError();

  let title = 'Erreur';
  let message = 'Une erreur inattendue est survenue.';

  if (isRouteErrorResponse(error)) {
    if (error.status === 404) {
      title = 'Page non trouvée';
      message = "La page que vous recherchez n'existe pas.";
    } else if (error.status === 403) {
      title = 'Accès refusé';
      message = "Vous n'avez pas les droits pour accéder à cette page.";
    }
  }

  return (
    <div className="error-page">
      <h1>{title}</h1>
      <p>{message}</p>
      <Link to="/">Retour à l'accueil</Link>
    </div>
  );
};
```

### Not Found Page

```typescript
// pages/NotFoundPage.tsx
import { Link } from 'react-router-dom';

const NotFoundPage: React.FC = () => {
  return (
    <div className="not-found-page">
      <h1>404</h1>
      <p>Page non trouvée</p>
      <Link to="/">Retour à l'accueil</Link>
    </div>
  );
};

export default NotFoundPage;
```

---

## Query Parameters

### useQueryParams Hook

```typescript
// hooks/useQueryParams.ts
import { useSearchParams } from 'react-router-dom';
import { useMemo, useCallback } from 'react';

interface ProductFilters {
  page: number;
  size: number;
  search: string;
  category: string;
  sort: string;
}

const defaultFilters: ProductFilters = {
  page: 0,
  size: 20,
  search: '',
  category: '',
  sort: 'createdAt,desc',
};

export const useProductFilters = () => {
  const [searchParams, setSearchParams] = useSearchParams();

  const filters = useMemo<ProductFilters>(() => ({
    page: parseInt(searchParams.get('page') || '0'),
    size: parseInt(searchParams.get('size') || '20'),
    search: searchParams.get('search') || '',
    category: searchParams.get('category') || '',
    sort: searchParams.get('sort') || 'createdAt,desc',
  }), [searchParams]);

  const setFilters = useCallback((updates: Partial<ProductFilters>) => {
    setSearchParams((prev) => {
      const newParams = new URLSearchParams(prev);
      Object.entries(updates).forEach(([key, value]) => {
        if (value === '' || value === defaultFilters[key as keyof ProductFilters]) {
          newParams.delete(key);
        } else {
          newParams.set(key, String(value));
        }
      });
      // Reset page when other filters change
      if ('search' in updates || 'category' in updates) {
        newParams.delete('page');
      }
      return newParams;
    });
  }, [setSearchParams]);

  const resetFilters = useCallback(() => {
    setSearchParams({});
  }, [setSearchParams]);

  return { filters, setFilters, resetFilters };
};
```

## App Entry Point

### src/App.tsx

```typescript
import { AuthProvider } from './contexts/AuthContext';
import { AppRouter } from './router';

export const App: React.FC = () => {
  return (
    <AuthProvider>
      <AppRouter />
    </AuthProvider>
  );
};
```

