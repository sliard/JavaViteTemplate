---
name: frontend-state
description: Manage global state with Zustand for React 19. Use this when asked to create stores, global state management, or persistent state.
---

# State Management with Zustand

Generate state management following project conventions for React 19 with Zustand.

## Required Dependencies

```json
{
  "dependencies": {
    "zustand": "^4.5.0"
  }
}
```

## Basic Store

### Simple Store

```typescript
// store/counterStore.ts
import { create } from 'zustand';

interface CounterState {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
  setCount: (count: number) => void;
}

export const useCounterStore = create<CounterState>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
  setCount: (count) => set({ count }),
}));

// Usage in component
const Counter: React.FC = () => {
  const { count, increment, decrement } = useCounterStore();
  
  return (
    <div>
      <span>{count}</span>
      <button onClick={increment}>+</button>
      <button onClick={decrement}>-</button>
    </div>
  );
};
```

---

## Shopping Cart Store

```typescript
// store/cartStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

interface CartItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
  imageUrl?: string;
}

interface CartState {
  items: CartItem[];
  isOpen: boolean;
  
  // Actions
  addItem: (product: Omit<CartItem, 'quantity'>) => void;
  removeItem: (productId: string) => void;
  updateQuantity: (productId: string, quantity: number) => void;
  clearCart: () => void;
  toggleCart: () => void;
  
  // Computed (selectors)
  getTotalItems: () => number;
  getTotalPrice: () => number;
  getItemQuantity: (productId: string) => number;
}

export const useCartStore = create<CartState>()(
  persist(
    (set, get) => ({
      items: [],
      isOpen: false,

      addItem: (product) => set((state) => {
        const existingItem = state.items.find(
          (item) => item.productId === product.productId
        );

        if (existingItem) {
          return {
            items: state.items.map((item) =>
              item.productId === product.productId
                ? { ...item, quantity: item.quantity + 1 }
                : item
            ),
          };
        }

        return {
          items: [...state.items, { ...product, quantity: 1 }],
        };
      }),

      removeItem: (productId) => set((state) => ({
        items: state.items.filter((item) => item.productId !== productId),
      })),

      updateQuantity: (productId, quantity) => set((state) => {
        if (quantity <= 0) {
          return {
            items: state.items.filter((item) => item.productId !== productId),
          };
        }

        return {
          items: state.items.map((item) =>
            item.productId === productId ? { ...item, quantity } : item
          ),
        };
      }),

      clearCart: () => set({ items: [] }),

      toggleCart: () => set((state) => ({ isOpen: !state.isOpen })),

      getTotalItems: () => {
        return get().items.reduce((total, item) => total + item.quantity, 0);
      },

      getTotalPrice: () => {
        return get().items.reduce(
          (total, item) => total + item.price * item.quantity,
          0
        );
      },

      getItemQuantity: (productId) => {
        const item = get().items.find((i) => i.productId === productId);
        return item?.quantity ?? 0;
      },
    }),
    {
      name: 'cart-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({ items: state.items }), // Only persist items
    }
  )
);
```

### Usage

```typescript
// components/AddToCartButton.tsx
export const AddToCartButton: React.FC<{ product: Product }> = ({ product }) => {
  const addItem = useCartStore((state) => state.addItem);
  const quantity = useCartStore((state) => state.getItemQuantity(product.id));

  const handleClick = () => {
    addItem({
      productId: product.id,
      name: product.name,
      price: product.price,
      imageUrl: product.imageUrl,
    });
  };

  return (
    <button onClick={handleClick}>
      {quantity > 0 ? `Dans le panier (${quantity})` : 'Ajouter au panier'}
    </button>
  );
};

// components/CartIcon.tsx
export const CartIcon: React.FC = () => {
  const totalItems = useCartStore((state) => state.getTotalItems());
  const toggleCart = useCartStore((state) => state.toggleCart);

  return (
    <button onClick={toggleCart} className="cart-icon">
      🛒 {totalItems > 0 && <span className="badge">{totalItems}</span>}
    </button>
  );
};
```

---

## Auth Store

```typescript
// store/authStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { authService } from '../services/authService';

interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
}

interface AuthState {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;

  // Actions
  login: (email: string, password: string) => Promise<void>;
  register: (data: RegisterData) => Promise<void>;
  logout: () => void;
  refreshAccessToken: () => Promise<void>;
  clearError: () => void;
  setUser: (user: User) => void;
}

interface RegisterData {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      accessToken: null,
      refreshToken: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      login: async (email, password) => {
        set({ isLoading: true, error: null });
        try {
          const response = await authService.login({ email, password });
          set({
            user: response.user,
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Erreur de connexion',
            isLoading: false,
          });
          throw error;
        }
      },

      register: async (data) => {
        set({ isLoading: true, error: null });
        try {
          const response = await authService.register(data);
          set({
            user: response.user,
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : "Erreur d'inscription",
            isLoading: false,
          });
          throw error;
        }
      },

      logout: () => {
        set({
          user: null,
          accessToken: null,
          refreshToken: null,
          isAuthenticated: false,
          error: null,
        });
      },

      refreshAccessToken: async () => {
        const { refreshToken } = get();
        if (!refreshToken) {
          get().logout();
          return;
        }

        try {
          const response = await authService.refresh(refreshToken);
          set({
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
          });
        } catch {
          get().logout();
        }
      },

      clearError: () => set({ error: null }),

      setUser: (user) => set({ user }),
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        user: state.user,
        accessToken: state.accessToken,
        refreshToken: state.refreshToken,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);

// Selector hooks for better performance
export const useUser = () => useAuthStore((state) => state.user);
export const useIsAuthenticated = () => useAuthStore((state) => state.isAuthenticated);
export const useAccessToken = () => useAuthStore((state) => state.accessToken);
```

---

## UI Store (Non-Persisted)

```typescript
// store/uiStore.ts
import { create } from 'zustand';

type Theme = 'light' | 'dark' | 'system';

interface Toast {
  id: string;
  type: 'success' | 'error' | 'info' | 'warning';
  message: string;
  duration?: number;
}

interface Modal {
  id: string;
  component: React.ComponentType<{ onClose: () => void }>;
  props?: Record<string, unknown>;
}

interface UIState {
  theme: Theme;
  sidebarOpen: boolean;
  toasts: Toast[];
  modals: Modal[];

  // Theme
  setTheme: (theme: Theme) => void;
  toggleTheme: () => void;

  // Sidebar
  toggleSidebar: () => void;
  setSidebarOpen: (open: boolean) => void;

  // Toasts
  showToast: (toast: Omit<Toast, 'id'>) => void;
  dismissToast: (id: string) => void;

  // Modals
  openModal: (modal: Omit<Modal, 'id'>) => void;
  closeModal: (id: string) => void;
  closeAllModals: () => void;
}

export const useUIStore = create<UIState>((set) => ({
  theme: 'system',
  sidebarOpen: true,
  toasts: [],
  modals: [],

  setTheme: (theme) => set({ theme }),

  toggleTheme: () => set((state) => ({
    theme: state.theme === 'light' ? 'dark' : 'light',
  })),

  toggleSidebar: () => set((state) => ({
    sidebarOpen: !state.sidebarOpen,
  })),

  setSidebarOpen: (open) => set({ sidebarOpen: open }),

  showToast: (toast) => {
    const id = crypto.randomUUID();
    set((state) => ({
      toasts: [...state.toasts, { ...toast, id }],
    }));

    // Auto-dismiss after duration
    const duration = toast.duration ?? 5000;
    if (duration > 0) {
      setTimeout(() => {
        set((state) => ({
          toasts: state.toasts.filter((t) => t.id !== id),
        }));
      }, duration);
    }
  },

  dismissToast: (id) => set((state) => ({
    toasts: state.toasts.filter((t) => t.id !== id),
  })),

  openModal: (modal) => {
    const id = crypto.randomUUID();
    set((state) => ({
      modals: [...state.modals, { ...modal, id }],
    }));
  },

  closeModal: (id) => set((state) => ({
    modals: state.modals.filter((m) => m.id !== id),
  })),

  closeAllModals: () => set({ modals: [] }),
}));

// Convenience hooks
export const useToast = () => {
  const showToast = useUIStore((state) => state.showToast);

  return {
    success: (message: string) => showToast({ type: 'success', message }),
    error: (message: string) => showToast({ type: 'error', message }),
    info: (message: string) => showToast({ type: 'info', message }),
    warning: (message: string) => showToast({ type: 'warning', message }),
  };
};
```

---

## Async Store with Immer

```typescript
// store/productsStore.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { productService } from '../services/productService';

interface Product {
  id: string;
  name: string;
  price: number;
}

interface ProductsState {
  products: Record<string, Product>;
  productIds: string[];
  loading: boolean;
  error: string | null;
  
  // Pagination
  page: number;
  totalPages: number;
  hasMore: boolean;

  // Actions
  fetchProducts: (page?: number) => Promise<void>;
  fetchProductById: (id: string) => Promise<void>;
  createProduct: (data: Omit<Product, 'id'>) => Promise<Product>;
  updateProduct: (id: string, data: Partial<Product>) => Promise<void>;
  deleteProduct: (id: string) => Promise<void>;

  // Selectors
  getProductById: (id: string) => Product | undefined;
  getAllProducts: () => Product[];
}

export const useProductsStore = create<ProductsState>()(
  immer((set, get) => ({
    products: {},
    productIds: [],
    loading: false,
    error: null,
    page: 0,
    totalPages: 0,
    hasMore: true,

    fetchProducts: async (page = 0) => {
      set({ loading: true, error: null });
      try {
        const response = await productService.findAll({ page, size: 20 });
        
        set((state) => {
          response.content.forEach((product) => {
            state.products[product.id] = product;
            if (!state.productIds.includes(product.id)) {
              state.productIds.push(product.id);
            }
          });
          state.page = response.number;
          state.totalPages = response.totalPages;
          state.hasMore = response.number < response.totalPages - 1;
          state.loading = false;
        });
      } catch (error) {
        set({
          error: error instanceof Error ? error.message : 'Erreur',
          loading: false,
        });
      }
    },

    fetchProductById: async (id) => {
      set({ loading: true, error: null });
      try {
        const product = await productService.findById(id);
        set((state) => {
          state.products[product.id] = product;
          if (!state.productIds.includes(product.id)) {
            state.productIds.push(product.id);
          }
          state.loading = false;
        });
      } catch (error) {
        set({
          error: error instanceof Error ? error.message : 'Erreur',
          loading: false,
        });
      }
    },

    createProduct: async (data) => {
      const product = await productService.create(data);
      set((state) => {
        state.products[product.id] = product;
        state.productIds.unshift(product.id);
      });
      return product;
    },

    updateProduct: async (id, data) => {
      const product = await productService.update(id, data);
      set((state) => {
        state.products[id] = product;
      });
    },

    deleteProduct: async (id) => {
      await productService.delete(id);
      set((state) => {
        delete state.products[id];
        state.productIds = state.productIds.filter((pid) => pid !== id);
      });
    },

    getProductById: (id) => get().products[id],

    getAllProducts: () => get().productIds.map((id) => get().products[id]),
  }))
);
```

---

## Store Slices (Large Applications)

```typescript
// store/slices/userSlice.ts
import { StateCreator } from 'zustand';

export interface UserSlice {
  user: User | null;
  setUser: (user: User | null) => void;
}

export const createUserSlice: StateCreator<UserSlice> = (set) => ({
  user: null,
  setUser: (user) => set({ user }),
});

// store/slices/settingsSlice.ts
export interface SettingsSlice {
  theme: 'light' | 'dark';
  language: string;
  setTheme: (theme: 'light' | 'dark') => void;
  setLanguage: (language: string) => void;
}

export const createSettingsSlice: StateCreator<SettingsSlice> = (set) => ({
  theme: 'light',
  language: 'fr',
  setTheme: (theme) => set({ theme }),
  setLanguage: (language) => set({ language }),
});

// store/index.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { createUserSlice, UserSlice } from './slices/userSlice';
import { createSettingsSlice, SettingsSlice } from './slices/settingsSlice';

type StoreState = UserSlice & SettingsSlice;

export const useStore = create<StoreState>()(
  persist(
    (...args) => ({
      ...createUserSlice(...args),
      ...createSettingsSlice(...args),
    }),
    {
      name: 'app-storage',
    }
  )
);
```

## Best Practices

1. **Keep stores focused** - One store per domain
2. **Use selectors** - Prevent unnecessary re-renders
3. **Persist only necessary state** - Use `partialize`
4. **Use Immer for complex updates** - Cleaner mutations
5. **Type everything** - Full TypeScript support
6. **Test stores** - They're just functions

