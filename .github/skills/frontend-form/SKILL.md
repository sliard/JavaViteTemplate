---
name: frontend-form
description: Generate forms with react-hook-form and zod validation for React 19. Use this when asked to create forms, form validation, or input handling.
---

# Form Generation with React Hook Form + Zod

Generate forms following project conventions for React 19 with react-hook-form and zod.

## Required Dependencies

```json
{
  "dependencies": {
    "react-hook-form": "^7.50.0",
    "@hookform/resolvers": "^3.3.0",
    "zod": "^3.22.0"
  }
}
```

## Basic Form Structure

### Schema Definition

```typescript
// schemas/productSchema.ts
import { z } from 'zod';

export const productSchema = z.object({
  name: z
    .string()
    .min(1, 'Le nom est obligatoire')
    .max(255, 'Le nom ne peut pas dépasser 255 caractères'),
  price: z
    .number({ required_error: 'Le prix est obligatoire', invalid_type_error: 'Le prix doit être un nombre' })
    .positive('Le prix doit être positif')
    .max(999999.99, 'Le prix ne peut pas dépasser 999 999,99 €'),
  description: z
    .string()
    .max(2000, 'La description ne peut pas dépasser 2000 caractères')
    .optional(),
  categoryId: z
    .string()
    .uuid('ID de catégorie invalide')
    .optional(),
});

export type ProductFormData = z.infer<typeof productSchema>;
```

### Form Component

```typescript
// components/ProductForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { productSchema, type ProductFormData } from '../schemas/productSchema';

interface ProductFormProps {
  defaultValues?: Partial<ProductFormData>;
  onSubmit: (data: ProductFormData) => Promise<void>;
  onCancel?: () => void;
  submitLabel?: string;
}

export const ProductForm: React.FC<ProductFormProps> = ({
  defaultValues,
  onSubmit,
  onCancel,
  submitLabel = 'Créer',
}) => {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
  } = useForm<ProductFormData>({
    resolver: zodResolver(productSchema),
    defaultValues: {
      name: '',
      price: undefined,
      description: '',
      ...defaultValues,
    },
  });

  const handleFormSubmit = async (data: ProductFormData) => {
    try {
      await onSubmit(data);
      reset();
    } catch (error) {
      // Error handling is done in parent component
      throw error;
    }
  };

  return (
    <form onSubmit={handleSubmit(handleFormSubmit)} noValidate>
      <div className="form-group">
        <label htmlFor="name">Nom *</label>
        <input
          id="name"
          type="text"
          {...register('name')}
          aria-invalid={!!errors.name}
          aria-describedby={errors.name ? 'name-error' : undefined}
        />
        {errors.name && (
          <span id="name-error" className="error" role="alert">
            {errors.name.message}
          </span>
        )}
      </div>

      <div className="form-group">
        <label htmlFor="price">Prix (€) *</label>
        <input
          id="price"
          type="number"
          step="0.01"
          {...register('price', { valueAsNumber: true })}
          aria-invalid={!!errors.price}
          aria-describedby={errors.price ? 'price-error' : undefined}
        />
        {errors.price && (
          <span id="price-error" className="error" role="alert">
            {errors.price.message}
          </span>
        )}
      </div>

      <div className="form-group">
        <label htmlFor="description">Description</label>
        <textarea
          id="description"
          rows={4}
          {...register('description')}
          aria-invalid={!!errors.description}
        />
        {errors.description && (
          <span className="error" role="alert">
            {errors.description.message}
          </span>
        )}
      </div>

      <div className="form-actions">
        {onCancel && (
          <button type="button" onClick={onCancel} disabled={isSubmitting}>
            Annuler
          </button>
        )}
        <button type="submit" disabled={isSubmitting}>
          {isSubmitting ? 'Chargement...' : submitLabel}
        </button>
      </div>
    </form>
  );
};
```

---

## Common Schema Patterns

### String Validations

```typescript
import { z } from 'zod';

// Required string
const name = z.string().min(1, 'Champ obligatoire');

// Email
const email = z.string().email('Email invalide');

// Password with requirements
const password = z
  .string()
  .min(8, 'Minimum 8 caractères')
  .regex(/[A-Z]/, 'Doit contenir une majuscule')
  .regex(/[a-z]/, 'Doit contenir une minuscule')
  .regex(/[0-9]/, 'Doit contenir un chiffre');

// URL
const url = z.string().url('URL invalide').optional().or(z.literal(''));

// Phone (French format)
const phone = z.string().regex(/^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$/, 'Numéro de téléphone invalide');

// Slug
const slug = z.string().regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/, 'Slug invalide');
```

### Number Validations

```typescript
// Positive number
const price = z.number().positive('Doit être positif');

// Integer
const quantity = z.number().int('Doit être un entier').min(0, 'Minimum 0');

// Range
const rating = z.number().min(1).max(5);

// Optional number (can be empty string from input)
const optionalNumber = z.preprocess(
  (val) => (val === '' ? undefined : Number(val)),
  z.number().positive().optional()
);
```

### Date Validations

```typescript
// Date string (ISO format)
const date = z.string().datetime({ message: 'Date invalide' });

// Date in the future
const futureDate = z.coerce.date().refine(
  (date) => date > new Date(),
  'La date doit être dans le futur'
);

// Date range
const dateRange = z.object({
  startDate: z.coerce.date(),
  endDate: z.coerce.date(),
}).refine(
  (data) => data.endDate > data.startDate,
  { message: 'La date de fin doit être après la date de début', path: ['endDate'] }
);
```

### Array Validations

```typescript
// Non-empty array
const tags = z.array(z.string()).min(1, 'Au moins un tag requis');

// Array with max items
const images = z.array(z.string().url()).max(5, 'Maximum 5 images');

// Array of objects
const items = z.array(
  z.object({
    productId: z.string().uuid(),
    quantity: z.number().int().positive(),
  })
).min(1, 'Au moins un article requis');
```

### Select/Enum Validations

```typescript
// Enum
const status = z.enum(['DRAFT', 'PUBLISHED', 'ARCHIVED'], {
  errorMap: () => ({ message: 'Statut invalide' }),
});

// Native enum
enum Role {
  USER = 'USER',
  ADMIN = 'ADMIN',
}
const role = z.nativeEnum(Role);

// Optional select (allows empty string)
const categoryId = z.string().uuid().optional().or(z.literal(''));
```

---

## Complex Form Examples

### Registration Form with Password Confirmation

```typescript
// schemas/registerSchema.ts
export const registerSchema = z.object({
  email: z.string().email('Email invalide'),
  password: z
    .string()
    .min(8, 'Minimum 8 caractères')
    .regex(/[A-Z]/, 'Doit contenir une majuscule')
    .regex(/[0-9]/, 'Doit contenir un chiffre'),
  confirmPassword: z.string(),
  firstName: z.string().min(1, 'Prénom obligatoire'),
  lastName: z.string().min(1, 'Nom obligatoire'),
  acceptTerms: z.boolean().refine((val) => val === true, {
    message: 'Vous devez accepter les conditions',
  }),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Les mots de passe ne correspondent pas',
  path: ['confirmPassword'],
});
```

### Dynamic Form (Array Fields)

```typescript
// components/OrderForm.tsx
import { useForm, useFieldArray } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

const orderSchema = z.object({
  customerId: z.string().uuid(),
  items: z.array(
    z.object({
      productId: z.string().uuid('Produit obligatoire'),
      quantity: z.number().int().min(1, 'Minimum 1'),
    })
  ).min(1, 'Au moins un article requis'),
  notes: z.string().optional(),
});

type OrderFormData = z.infer<typeof orderSchema>;

export const OrderForm: React.FC = () => {
  const { register, control, handleSubmit, formState: { errors } } = useForm<OrderFormData>({
    resolver: zodResolver(orderSchema),
    defaultValues: {
      items: [{ productId: '', quantity: 1 }],
    },
  });

  const { fields, append, remove } = useFieldArray({
    control,
    name: 'items',
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      {fields.map((field, index) => (
        <div key={field.id} className="item-row">
          <select {...register(`items.${index}.productId`)}>
            <option value="">Sélectionner un produit</option>
            {/* Options */}
          </select>
          {errors.items?.[index]?.productId && (
            <span className="error">{errors.items[index].productId.message}</span>
          )}

          <input
            type="number"
            {...register(`items.${index}.quantity`, { valueAsNumber: true })}
          />
          
          {fields.length > 1 && (
            <button type="button" onClick={() => remove(index)}>
              Supprimer
            </button>
          )}
        </div>
      ))}

      <button type="button" onClick={() => append({ productId: '', quantity: 1 })}>
        Ajouter un article
      </button>

      {errors.items?.root && (
        <span className="error">{errors.items.root.message}</span>
      )}

      <button type="submit">Commander</button>
    </form>
  );
};
```

### Conditional Fields

```typescript
const userSchema = z.discriminatedUnion('type', [
  z.object({
    type: z.literal('individual'),
    firstName: z.string().min(1),
    lastName: z.string().min(1),
  }),
  z.object({
    type: z.literal('company'),
    companyName: z.string().min(1),
    siret: z.string().length(14, 'SIRET invalide'),
  }),
]);

export const UserTypeForm: React.FC = () => {
  const { register, watch, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(userSchema),
  });

  const userType = watch('type');

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <select {...register('type')}>
        <option value="individual">Particulier</option>
        <option value="company">Entreprise</option>
      </select>

      {userType === 'individual' && (
        <>
          <input {...register('firstName')} placeholder="Prénom" />
          <input {...register('lastName')} placeholder="Nom" />
        </>
      )}

      {userType === 'company' && (
        <>
          <input {...register('companyName')} placeholder="Raison sociale" />
          <input {...register('siret')} placeholder="SIRET" />
        </>
      )}

      <button type="submit">Valider</button>
    </form>
  );
};
```

---

## Reusable Form Components

### Input Component

```typescript
// components/form/Input.tsx
import { UseFormRegisterReturn } from 'react-hook-form';

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
  registration: UseFormRegisterReturn;
}

export const Input: React.FC<InputProps> = ({
  label,
  error,
  registration,
  type = 'text',
  ...props
}) => {
  const id = registration.name;

  return (
    <div className="form-group">
      <label htmlFor={id}>{label}</label>
      <input
        id={id}
        type={type}
        {...registration}
        {...props}
        aria-invalid={!!error}
        aria-describedby={error ? `${id}-error` : undefined}
      />
      {error && (
        <span id={`${id}-error`} className="error" role="alert">
          {error}
        </span>
      )}
    </div>
  );
};

// Usage
<Input
  label="Nom du produit"
  registration={register('name')}
  error={errors.name?.message}
/>
```

### Select Component

```typescript
// components/form/Select.tsx
interface SelectOption {
  value: string;
  label: string;
}

interface SelectProps {
  label: string;
  options: SelectOption[];
  error?: string;
  registration: UseFormRegisterReturn;
  placeholder?: string;
}

export const Select: React.FC<SelectProps> = ({
  label,
  options,
  error,
  registration,
  placeholder = 'Sélectionner...',
}) => {
  const id = registration.name;

  return (
    <div className="form-group">
      <label htmlFor={id}>{label}</label>
      <select
        id={id}
        {...registration}
        aria-invalid={!!error}
      >
        <option value="">{placeholder}</option>
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
      {error && <span className="error" role="alert">{error}</span>}
    </div>
  );
};
```

---

## Form Hook Pattern

```typescript
// hooks/useProductForm.ts
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { productSchema, ProductFormData } from '../schemas/productSchema';
import { useCreateProduct } from './useCreateProduct';
import { useUpdateProduct } from './useUpdateProduct';

interface UseProductFormOptions {
  mode: 'create' | 'edit';
  productId?: string;
  defaultValues?: Partial<ProductFormData>;
  onSuccess?: () => void;
}

export const useProductForm = ({
  mode,
  productId,
  defaultValues,
  onSuccess,
}: UseProductFormOptions) => {
  const form = useForm<ProductFormData>({
    resolver: zodResolver(productSchema),
    defaultValues,
  });

  const createMutation = useCreateProduct({ onSuccess });
  const updateMutation = useUpdateProduct({ onSuccess });

  const onSubmit = async (data: ProductFormData) => {
    if (mode === 'create') {
      await createMutation.createProduct(data);
    } else {
      await updateMutation.updateProduct(productId!, data);
    }
  };

  return {
    ...form,
    onSubmit: form.handleSubmit(onSubmit),
    isLoading: createMutation.loading || updateMutation.loading,
    error: createMutation.error || updateMutation.error,
  };
};
```

## Best Practices

1. **Define schemas in separate files** - Easier to test and reuse
2. **Use `valueAsNumber` for number inputs** - Avoids string conversion issues
3. **Add `noValidate` to form** - Disable browser validation, rely on zod
4. **Use `aria-invalid` and `aria-describedby`** - Accessibility
5. **Handle loading state** - Disable submit button during submission
6. **Reset form on success** - Clear fields after successful submission

