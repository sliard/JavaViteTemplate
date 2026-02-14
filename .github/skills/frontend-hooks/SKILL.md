---
name: frontend-hooks
description: Generate custom React hooks for React 19 with TypeScript. Use this when asked to create reusable logic, data fetching hooks, form hooks, or any custom hook.
---

# Custom React Hooks

Generate custom hooks following project conventions for React 19 with TypeScript.

## Hook Structure

```tsx
interface UseHookNameOptions {
  // Input options
}

interface UseHookNameResult {
  // Return values
}

export const useHookName = (options: UseHookNameOptions = {}): UseHookNameResult => {
  // Implementation
  return { /* values */ };
};
```

## Naming Convention

- Prefix with `use`: `useProducts`, `useAuth`, `useLocalStorage`
- File name matches hook name: `useProducts.ts`
- Options interface: `Use{HookName}Options`
- Result interface: `Use{HookName}Result`

## Data Fetching Hook

```tsx
interface UseProductsOptions {
  categoryId?: string;
  page?: number;
  size?: number;
}

interface UseProductsResult {
  products: Product[];
  loading: boolean;
  error: Error | null;
  refetch: () => Promise<void>;
}

export const useProducts = (options: UseProductsOptions = {}): UseProductsResult => {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchProducts = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await productService.findAll(options);
      setProducts(data.content);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Unknown error'));
    } finally {
      setLoading(false);
    }
  }, [options.categoryId, options.page, options.size]);

  useEffect(() => {
    fetchProducts();
  }, [fetchProducts]);

  return { products, loading, error, refetch: fetchProducts };
};
```

## Single Item Hook with Cache

```tsx
const cache = new Map<string, Product>();

export const useProduct = (id: string | undefined): UseProductResult => {
  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    if (!id) return;

    // Check cache first
    const cached = cache.get(id);
    if (cached) {
      setProduct(cached);
      return;
    }

    const fetchProduct = async () => {
      setLoading(true);
      try {
        const data = await productService.findById(id);
        cache.set(id, data);
        setProduct(data);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Not found'));
      } finally {
        setLoading(false);
      }
    };

    fetchProduct();
  }, [id]);

  return { product, loading, error };
};
```

## Mutation Hook

```tsx
interface UseCreateProductResult {
  create: (data: ProductRequest) => Promise<Product>;
  loading: boolean;
  error: Error | null;
  reset: () => void;
}

export const useCreateProduct = (): UseCreateProductResult => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const create = useCallback(async (data: ProductRequest): Promise<Product> => {
    setLoading(true);
    setError(null);
    try {
      return await productService.create(data);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Create failed');
      setError(error);
      throw error;
    } finally {
      setLoading(false);
    }
  }, []);

  const reset = useCallback(() => setError(null), []);

  return { create, loading, error, reset };
};
```

## Debounce Hook

```tsx
export const useDebounce = <T>(value: T, delay: number = 300): T => {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
};
```

## LocalStorage Hook

```tsx
export const useLocalStorage = <T>(key: string, initialValue: T): [T, (value: T) => void] => {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = useCallback((value: T) => {
    setStoredValue(value);
    localStorage.setItem(key, JSON.stringify(value));
  }, [key]);

  return [storedValue, setValue];
};
```

## Media Query Hook

```tsx
export const useMediaQuery = (query: string): boolean => {
  const [matches, setMatches] = useState(() => 
    window.matchMedia(query).matches
  );

  useEffect(() => {
    const mediaQuery = window.matchMedia(query);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);
    mediaQuery.addEventListener('change', handler);
    return () => mediaQuery.removeEventListener('change', handler);
  }, [query]);

  return matches;
};

// Derived hooks
export const useIsMobile = () => useMediaQuery('(max-width: 768px)');
```

## Click Outside Hook

```tsx
export const useClickOutside = <T extends HTMLElement>(
  callback: () => void
): RefObject<T> => {
  const ref = useRef<T>(null);

  useEffect(() => {
    const handleClick = (event: MouseEvent) => {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        callback();
      }
    };

    document.addEventListener('mousedown', handleClick);
    return () => document.removeEventListener('mousedown', handleClick);
  }, [callback]);

  return ref;
};
```

## Best Practices

1. Always return typed objects, not arrays
2. Include `loading` and `error` states for async hooks
3. Provide `refetch` or `reset` functions when applicable
4. Use `useCallback` for returned functions
5. Clean up effects (timers, listeners, abort controllers)

