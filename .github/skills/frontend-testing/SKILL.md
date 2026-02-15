---
name: frontend-testing
description: Generate tests for React 19 components and hooks with Vitest, Testing Library, and MSW. Use this when asked to create unit tests, integration tests, or component tests.
---

# Frontend Testing Generation

Generate tests following project conventions for React 19 with Vitest, Testing Library, and MSW.

## Required Dependencies

```json
{
  "devDependencies": {
    "@testing-library/jest-dom": "^6.4.0",
    "@testing-library/react": "^14.2.0",
    "@testing-library/user-event": "^14.5.0",
    "@types/jest": "^29.5.0",
    "jsdom": "^24.0.0",
    "msw": "^2.2.0",
    "vitest": "^1.3.0"
  }
}
```

## Configuration

### vite.config.ts

```typescript
/// <reference types="vitest" />
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    include: ['**/*.{test,spec}.{ts,tsx}'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.d.ts',
        '**/*.config.*',
        '**/index.ts',
      ],
      thresholds: {
        statements: 75,
        branches: 75,
        functions: 75,
        lines: 75,
      },
    },
  },
});
```

### src/test/setup.ts

```typescript
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { afterEach, beforeAll, afterAll } from 'vitest';
import { server } from './mocks/server';

// Start MSW server
beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => {
  cleanup();
  server.resetHandlers();
});
afterAll(() => server.close());
```

## MSW Setup

### src/test/mocks/handlers.ts

```typescript
import { http, HttpResponse } from 'msw';

const API_URL = 'http://localhost:8080/api';

export const handlers = [
  // Products
  http.get(`${API_URL}/products`, () => {
    return HttpResponse.json({
      content: [
        { id: '1', name: 'Product 1', price: 99.99, createdAt: '2024-01-01T00:00:00Z' },
        { id: '2', name: 'Product 2', price: 149.99, createdAt: '2024-01-02T00:00:00Z' },
      ],
      totalElements: 2,
      totalPages: 1,
      number: 0,
      size: 20,
    });
  }),

  http.get(`${API_URL}/products/:id`, ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'Test Product',
      price: 99.99,
      createdAt: '2024-01-01T00:00:00Z',
    });
  }),

  http.post(`${API_URL}/products`, async ({ request }) => {
    const body = await request.json() as { name: string; price: number };
    return HttpResponse.json(
      { id: 'new-id', ...body, createdAt: new Date().toISOString() },
      { status: 201 }
    );
  }),

  // Auth
  http.post(`${API_URL}/auth/login`, async ({ request }) => {
    const body = await request.json() as { email: string; password: string };
    if (body.email === 'test@example.com' && body.password === 'password') {
      return HttpResponse.json({
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
        user: { id: '1', email: body.email, role: 'USER' },
      });
    }
    return HttpResponse.json(
      { code: 'INVALID_CREDENTIALS', message: 'Invalid credentials' },
      { status: 401 }
    );
  }),
];
```

### src/test/mocks/server.ts

```typescript
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

---

## Component Tests

### Basic Component Test

```typescript
// ProductCard.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { ProductCard } from './ProductCard';

const mockProduct = {
  id: '1',
  name: 'Test Product',
  price: 99.99,
  createdAt: '2024-01-01T00:00:00Z',
};

describe('ProductCard', () => {
  it('should render product information', () => {
    render(<ProductCard product={mockProduct} />);

    expect(screen.getByText('Test Product')).toBeInTheDocument();
    expect(screen.getByText('99,99 €')).toBeInTheDocument();
  });

  it('should call onAddToCart when button is clicked', async () => {
    const user = userEvent.setup();
    const onAddToCart = vi.fn();

    render(<ProductCard product={mockProduct} onAddToCart={onAddToCart} />);

    await user.click(screen.getByRole('button', { name: /ajouter/i }));

    expect(onAddToCart).toHaveBeenCalledTimes(1);
    expect(onAddToCart).toHaveBeenCalledWith(mockProduct);
  });

  it('should not render add button when onAddToCart is not provided', () => {
    render(<ProductCard product={mockProduct} />);

    expect(screen.queryByRole('button', { name: /ajouter/i })).not.toBeInTheDocument();
  });
});
```

### Form Component Test

```typescript
// ProductForm.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { ProductForm } from './ProductForm';

describe('ProductForm', () => {
  it('should submit form with valid data', async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();

    render(<ProductForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText(/nom/i), 'New Product');
    await user.type(screen.getByLabelText(/prix/i), '49.99');
    await user.click(screen.getByRole('button', { name: /créer/i }));

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        name: 'New Product',
        price: 49.99,
      });
    });
  });

  it('should show validation errors for empty fields', async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();

    render(<ProductForm onSubmit={onSubmit} />);

    await user.click(screen.getByRole('button', { name: /créer/i }));

    await waitFor(() => {
      expect(screen.getByText(/nom est obligatoire/i)).toBeInTheDocument();
    });
    expect(onSubmit).not.toHaveBeenCalled();
  });

  it('should disable submit button while submitting', async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn(() => new Promise((resolve) => setTimeout(resolve, 100)));

    render(<ProductForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText(/nom/i), 'New Product');
    await user.type(screen.getByLabelText(/prix/i), '49.99');

    const submitButton = screen.getByRole('button', { name: /créer/i });
    await user.click(submitButton);

    expect(submitButton).toBeDisabled();
  });
});
```

### Component with Loading/Error States

```typescript
// ProductList.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { ProductList } from './ProductList';
import { server } from '../test/mocks/server';
import { http, HttpResponse } from 'msw';

describe('ProductList', () => {
  it('should show loading state initially', () => {
    render(<ProductList />);

    expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
  });

  it('should render products after loading', async () => {
    render(<ProductList />);

    await waitFor(() => {
      expect(screen.getByText('Product 1')).toBeInTheDocument();
    });
    expect(screen.getByText('Product 2')).toBeInTheDocument();
  });

  it('should show error message when fetch fails', async () => {
    server.use(
      http.get('http://localhost:8080/api/products', () => {
        return HttpResponse.json(
          { code: 'SERVER_ERROR', message: 'Internal server error' },
          { status: 500 }
        );
      })
    );

    render(<ProductList />);

    await waitFor(() => {
      expect(screen.getByText(/erreur/i)).toBeInTheDocument();
    });
  });

  it('should show empty state when no products', async () => {
    server.use(
      http.get('http://localhost:8080/api/products', () => {
        return HttpResponse.json({
          content: [],
          totalElements: 0,
          totalPages: 0,
          number: 0,
          size: 20,
        });
      })
    );

    render(<ProductList />);

    await waitFor(() => {
      expect(screen.getByText(/aucun produit/i)).toBeInTheDocument();
    });
  });
});
```

---

## Hook Tests

### Data Fetching Hook

```typescript
// useProducts.test.ts
import { renderHook, waitFor } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { useProducts } from './useProducts';
import { server } from '../test/mocks/server';
import { http, HttpResponse } from 'msw';

describe('useProducts', () => {
  it('should return loading state initially', () => {
    const { result } = renderHook(() => useProducts());

    expect(result.current.loading).toBe(true);
    expect(result.current.products).toEqual([]);
    expect(result.current.error).toBeNull();
  });

  it('should fetch products successfully', async () => {
    const { result } = renderHook(() => useProducts());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.products).toHaveLength(2);
    expect(result.current.products[0].name).toBe('Product 1');
    expect(result.current.error).toBeNull();
  });

  it('should handle fetch error', async () => {
    server.use(
      http.get('http://localhost:8080/api/products', () => {
        return HttpResponse.json(null, { status: 500 });
      })
    );

    const { result } = renderHook(() => useProducts());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.error).not.toBeNull();
    expect(result.current.products).toEqual([]);
  });

  it('should refetch when refetch is called', async () => {
    const { result } = renderHook(() => useProducts());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    // Simulate updated data
    server.use(
      http.get('http://localhost:8080/api/products', () => {
        return HttpResponse.json({
          content: [{ id: '3', name: 'Updated Product', price: 199.99 }],
          totalElements: 1,
          totalPages: 1,
          number: 0,
          size: 20,
        });
      })
    );

    result.current.refetch();

    await waitFor(() => {
      expect(result.current.products[0].name).toBe('Updated Product');
    });
  });
});
```

### Mutation Hook

```typescript
// useCreateProduct.test.ts
import { renderHook, waitFor, act } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { useCreateProduct } from './useCreateProduct';

describe('useCreateProduct', () => {
  it('should have initial state', () => {
    const { result } = renderHook(() => useCreateProduct());

    expect(result.current.loading).toBe(false);
    expect(result.current.error).toBeNull();
    expect(result.current.data).toBeNull();
  });

  it('should create product successfully', async () => {
    const { result } = renderHook(() => useCreateProduct());

    await act(async () => {
      await result.current.createProduct({
        name: 'New Product',
        price: 49.99,
      });
    });

    expect(result.current.data).not.toBeNull();
    expect(result.current.data?.name).toBe('New Product');
    expect(result.current.error).toBeNull();
  });

  it('should call onSuccess callback', async () => {
    const onSuccess = vi.fn();
    const { result } = renderHook(() => useCreateProduct({ onSuccess }));

    await act(async () => {
      await result.current.createProduct({
        name: 'New Product',
        price: 49.99,
      });
    });

    expect(onSuccess).toHaveBeenCalledWith(expect.objectContaining({
      name: 'New Product',
    }));
  });
});
```

### Utility Hook

```typescript
// useDebounce.test.ts
import { renderHook, act } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { useDebounce } from './useDebounce';

describe('useDebounce', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('should return initial value immediately', () => {
    const { result } = renderHook(() => useDebounce('initial', 500));

    expect(result.current).toBe('initial');
  });

  it('should debounce value changes', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 500),
      { initialProps: { value: 'initial' } }
    );

    rerender({ value: 'updated' });

    // Value should not change immediately
    expect(result.current).toBe('initial');

    // Fast-forward time
    act(() => {
      vi.advanceTimersByTime(500);
    });

    expect(result.current).toBe('updated');
  });

  it('should cancel previous timeout on rapid changes', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 500),
      { initialProps: { value: 'initial' } }
    );

    rerender({ value: 'first' });
    act(() => {
      vi.advanceTimersByTime(200);
    });

    rerender({ value: 'second' });
    act(() => {
      vi.advanceTimersByTime(200);
    });

    rerender({ value: 'final' });
    act(() => {
      vi.advanceTimersByTime(500);
    });

    expect(result.current).toBe('final');
  });
});
```

---

## Test Utilities

### Custom Render with Providers

```typescript
// src/test/utils.tsx
import { ReactElement } from 'react';
import { render, RenderOptions } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { AuthProvider } from '../contexts/AuthContext';

interface WrapperProps {
  children: React.ReactNode;
}

const AllProviders = ({ children }: WrapperProps) => {
  return (
    <BrowserRouter>
      <AuthProvider>
        {children}
      </AuthProvider>
    </BrowserRouter>
  );
};

const customRender = (
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
) => render(ui, { wrapper: AllProviders, ...options });

export * from '@testing-library/react';
export { customRender as render };
```

### Mock Auth Context

```typescript
// src/test/mocks/authContext.tsx
import { vi } from 'vitest';

export const mockUser = {
  id: '1',
  email: 'test@example.com',
  firstName: 'Test',
  lastName: 'User',
  role: 'USER',
};

export const mockAuthContext = {
  user: mockUser,
  isAuthenticated: true,
  loading: false,
  login: vi.fn(),
  logout: vi.fn(),
  register: vi.fn(),
};

export const mockUnauthenticatedContext = {
  user: null,
  isAuthenticated: false,
  loading: false,
  login: vi.fn(),
  logout: vi.fn(),
  register: vi.fn(),
};
```

### Test Data Factories

```typescript
// src/test/factories.ts
import { Product, User } from '../types';

export const createProduct = (overrides?: Partial<Product>): Product => ({
  id: crypto.randomUUID(),
  name: 'Test Product',
  price: 99.99,
  description: 'Test description',
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
  ...overrides,
});

export const createUser = (overrides?: Partial<User>): User => ({
  id: crypto.randomUUID(),
  email: 'test@example.com',
  firstName: 'Test',
  lastName: 'User',
  role: 'USER',
  ...overrides,
});

export const createProducts = (count: number): Product[] =>
  Array.from({ length: count }, (_, i) =>
    createProduct({ id: `${i + 1}`, name: `Product ${i + 1}` })
  );
```

---

## Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm test -- --watch

# Run tests with coverage
npm test -- --coverage

# Run specific test file
npm test -- ProductCard.test.tsx

# Run tests matching pattern
npm test -- --grep "should render"
```

## Package.json Scripts

```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "test:ui": "vitest --ui"
  }
}
```

