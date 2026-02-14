---
name: frontend-services
description: Generate API service modules for React 19 with TypeScript. Use this when asked to create API clients, HTTP services, or backend communication layers.
---

# API Services

Generate API services following project conventions for React 19 with TypeScript.

## API Client (services/api.ts)

```tsx
const API_URL = import.meta.env.VITE_API_URL;

class ApiClient {
  private getToken(): string | null {
    return localStorage.getItem('access_token');
  }

  async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const token = this.getToken();
    
    const response = await fetch(`${API_URL}${endpoint}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
        ...options.headers,
      },
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ message: response.statusText }));
      throw new ApiError(response.status, error.message);
    }

    if (response.status === 204) return undefined as T;
    return response.json();
  }

  get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'GET' });
  }

  post<T>(endpoint: string, body?: unknown): Promise<T> {
    return this.request<T>(endpoint, { method: 'POST', body: JSON.stringify(body) });
  }

  put<T>(endpoint: string, body?: unknown): Promise<T> {
    return this.request<T>(endpoint, { method: 'PUT', body: JSON.stringify(body) });
  }

  delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'DELETE' });
  }
}

export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = 'ApiError';
  }

  isNotFound() { return this.status === 404; }
  isUnauthorized() { return this.status === 401; }
}

export const api = new ApiClient();
```

## Types (types/common.ts)

```tsx
export interface Page<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;
  size: number;
}

export interface PaginationParams {
  page?: number;
  size?: number;
  sort?: string;
}

export const buildQueryParams = (params: Record<string, unknown>): string => {
  const searchParams = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      searchParams.append(key, String(value));
    }
  });
  const query = searchParams.toString();
  return query ? `?${query}` : '';
};
```

## Service Module Pattern

```tsx
// services/productService.ts
import { api } from './api';
import { Page, PaginationParams, buildQueryParams } from '../types/common';
import { Product, ProductRequest } from '../types/product';

export const productService = {
  async findAll(params?: PaginationParams): Promise<Page<Product>> {
    return api.get(`/products${buildQueryParams(params ?? {})}`);
  },

  async findById(id: string): Promise<Product> {
    return api.get(`/products/${id}`);
  },

  async create(data: ProductRequest): Promise<Product> {
    return api.post('/products', data);
  },

  async update(id: string, data: ProductRequest): Promise<Product> {
    return api.put(`/products/${id}`, data);
  },

  async delete(id: string): Promise<void> {
    return api.delete(`/products/${id}`);
  },

  async search(query: string, params?: PaginationParams): Promise<Page<Product>> {
    return api.get(`/products${buildQueryParams({ ...params, name: query })}`);
  },
};
```

## Types for Services

```tsx
// types/product.ts
export interface Product {
  id: string;
  name: string;
  price: number;
  description: string | null;
  categoryName: string;
  createdAt: string;
}

export interface ProductRequest {
  name: string;
  price: number;
  description?: string;
  categoryId: string;
}

export interface ProductFilter {
  name?: string;
  categoryId?: string;
  minPrice?: number;
  maxPrice?: number;
}
```

## File Upload Service

```tsx
export const uploadService = {
  async uploadFile(file: File, onProgress?: (percent: number) => void): Promise<UploadResult> {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      
      xhr.upload.addEventListener('progress', (e) => {
        if (e.lengthComputable && onProgress) {
          onProgress(Math.round((e.loaded / e.total) * 100));
        }
      });

      xhr.addEventListener('load', () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          resolve(JSON.parse(xhr.responseText));
        } else {
          reject(new Error('Upload failed'));
        }
      });

      const formData = new FormData();
      formData.append('file', file);

      xhr.open('POST', `${API_URL}/files/upload`);
      const token = localStorage.getItem('access_token');
      if (token) xhr.setRequestHeader('Authorization', `Bearer ${token}`);
      xhr.send(formData);
    });
  },
};
```

## Usage with Hooks

```tsx
// hooks/useProducts.ts
export const useProducts = (params?: PaginationParams) => {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<ApiError | null>(null);

  const fetchProducts = useCallback(async () => {
    setLoading(true);
    try {
      const data = await productService.findAll(params);
      setProducts(data.content);
    } catch (err) {
      setError(err instanceof ApiError ? err : new ApiError(500, 'Unknown error'));
    } finally {
      setLoading(false);
    }
  }, [params]);

  useEffect(() => { fetchProducts(); }, [fetchProducts]);

  return { products, loading, error, refetch: fetchProducts };
};
```

## Environment Variables

```env
VITE_API_URL=http://localhost:8080/api
```

Access via: `import.meta.env.VITE_API_URL`

