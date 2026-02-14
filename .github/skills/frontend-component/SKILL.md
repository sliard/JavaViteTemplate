---
name: frontend-component
description: Generate React functional components with TypeScript for React 19 and Vite 6. Use this when asked to create UI components, buttons, cards, forms, modals, or any React component.
---

# React Component Generation

Generate React components following project conventions for React 19, TypeScript 5.x, and Vite 6.

## Component Structure

```tsx
import { type FC } from 'react';

interface ComponentNameProps {
  // Props definition
}

export const ComponentName: FC<ComponentNameProps> = ({ /* destructured props */ }) => {
  return (
    <div className="component-name">
      {/* Content */}
    </div>
  );
};
```

## Naming Conventions

- File name: PascalCase matching component name (`ProductCard.tsx`)
- Component: PascalCase (`ProductCard`)
- Props interface: `{ComponentName}Props`
- Hooks: camelCase with `use` prefix (`useProducts`)

## Rules

1. **Functional components only** - No class components
2. **Named exports** - No default exports
3. **TypeScript strict** - All props must be typed
4. **Props interface** - Always define a Props interface

## Props Patterns

```tsx
interface ButtonProps {
  children: React.ReactNode;           // Required content
  variant?: 'primary' | 'secondary';   // Optional with union type
  disabled?: boolean;                  // Optional boolean
  onClick?: () => void;                // Optional callback
  onSubmit?: (data: FormData) => void; // Callback with parameter
}
```

## Component Examples

### Simple Component

```tsx
interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  onClick?: () => void;
}

export const Button: FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  disabled = false,
  onClick,
}) => {
  return (
    <button
      className={`btn btn--${variant} btn--${size}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
```

### Component with State

```tsx
interface CounterProps {
  initialValue?: number;
  onChange?: (value: number) => void;
}

export const Counter: FC<CounterProps> = ({ initialValue = 0, onChange }) => {
  const [count, setCount] = useState(initialValue);

  const increment = () => {
    const newValue = count + 1;
    setCount(newValue);
    onChange?.(newValue);
  };

  return (
    <div className="counter">
      <span>{count}</span>
      <button onClick={increment}>+</button>
    </div>
  );
};
```

### Component with Loading/Error States

```tsx
interface ProductListProps {
  categoryId?: string;
}

export const ProductList: FC<ProductListProps> = ({ categoryId }) => {
  const { products, loading, error, refetch } = useProducts({ categoryId });

  if (loading) return <Spinner />;
  
  if (error) return <ErrorMessage message={error.message} onRetry={refetch} />;
  
  if (products.length === 0) return <EmptyState message="No products found" />;

  return (
    <div className="product-list">
      {products.map((product) => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  );
};
```

### Form Component

```tsx
interface ProductFormProps {
  initialData?: Partial<ProductRequest>;
  onSubmit: (data: ProductRequest) => Promise<void>;
  isLoading?: boolean;
}

export const ProductForm: FC<ProductFormProps> = ({
  initialData,
  onSubmit,
  isLoading = false,
}) => {
  const [formData, setFormData] = useState<ProductRequest>({
    name: initialData?.name ?? '',
    price: initialData?.price ?? 0,
  });

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    await onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={formData.name}
        onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
        disabled={isLoading}
      />
      <button type="submit" disabled={isLoading}>
        {isLoading ? 'Saving...' : 'Save'}
      </button>
    </form>
  );
};
```

## Accessibility

- Use semantic HTML (`<button>`, `<nav>`, `<article>`)
- Add `aria-label` for icon buttons
- Support keyboard navigation
- Handle focus management for modals

## Performance

- Use `useCallback` for callbacks passed as props
- Use `React.memo` for frequently re-rendered pure components
- Use `React.lazy` for large components

