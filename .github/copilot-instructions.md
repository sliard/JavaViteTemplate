# Instructions GitHub Copilot

Ce fichier définit les conventions et bonnes pratiques pour ce projet fullstack.

## 🎯 Contexte du projet

Ce projet utilise :
- **Backend** : Java 21, Spring Boot 3.4.x, Spring Security 6.x, Spring Data JPA, PostgreSQL 16
- **Frontend** : Node.js 22, React 19, Vite 6.x, TypeScript 5.x
- **Infrastructure** : Docker, Docker Compose, Nginx

## 📐 Architecture

### Backend - Architecture en couches

```
controller/  → Endpoints REST, validation des entrées
    ↓
service/     → Logique métier, transactions
    ↓
repository/  → Accès données JPA
    ↓
entity/      → Modèles de données
```

### Frontend - Structure fonctionnelle

```
pages/       → Composants de page (routes)
components/  → Composants réutilisables
hooks/       → Logique réutilisable
services/    → Appels API
store/       → État global (si nécessaire)
types/       → Définitions TypeScript
```

---

## ☕ Conventions Backend (Java/Spring Boot)

### Entités JPA

```java
@Entity
@Table(name = "products")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String name;

    @Column(precision = 10, scale = 2)
    private BigDecimal price;

    @CreatedDate
    @Column(updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}
```

**Règles :**
- Utiliser UUID comme type d'ID
- Toujours inclure `createdAt` et `updatedAt`
- Utiliser `@Data` de Lombok
- Nommer les tables au pluriel en snake_case

### DTOs

```java
public record ProductRequest(
    @NotBlank(message = "Le nom est obligatoire")
    @Size(max = 255)
    String name,

    @NotNull(message = "Le prix est obligatoire")
    @Positive(message = "Le prix doit être positif")
    BigDecimal price
) {}

public record ProductResponse(
    UUID id,
    String name,
    BigDecimal price,
    Instant createdAt
) {}
```

**Règles :**
- Utiliser des records Java
- Suffixes : `Request`, `Response`, `ListResponse`
- Validation avec Bean Validation

### Controllers

```java
@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
@Tag(name = "Products", description = "Gestion des produits")
public class ProductController {

    private final ProductService productService;

    @GetMapping
    public ResponseEntity<Page<ProductResponse>> findAll(Pageable pageable) {
        return ResponseEntity.ok(productService.findAll(pageable));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ProductResponse create(@Valid @RequestBody ProductRequest request) {
        return productService.create(request);
    }
}
```

**Règles :**
- Préfixer les endpoints avec `/api/`
- Utiliser `ResponseEntity` pour les réponses avec headers
- Injection par constructeur avec `@RequiredArgsConstructor`
- Documentation OpenAPI avec `@Tag` et `@Operation`

### Services

```java
public interface ProductService {
    Page<ProductResponse> findAll(Pageable pageable);
    ProductResponse create(ProductRequest request);
}

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;

    @Override
    public Page<ProductResponse> findAll(Pageable pageable) {
        return productRepository.findAll(pageable)
            .map(this::toResponse);
    }

    @Override
    @Transactional
    public ProductResponse create(ProductRequest request) {
        var product = Product.builder()
            .name(request.name())
            .price(request.price())
            .build();
        return toResponse(productRepository.save(product));
    }

    private ProductResponse toResponse(Product product) {
        return new ProductResponse(
            product.getId(),
            product.getName(),
            product.getPrice(),
            product.getCreatedAt()
        );
    }
}
```

**Règles :**
- Interface + Implémentation
- `@Transactional(readOnly = true)` par défaut
- `@Transactional` sur les méthodes qui modifient

### Gestion des erreurs

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(EntityNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse("NOT_FOUND", ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        var errors = ex.getBindingResult().getFieldErrors().stream()
            .map(e -> e.getField() + ": " + e.getDefaultMessage())
            .toList();
        return ResponseEntity.badRequest()
            .body(new ErrorResponse("VALIDATION_ERROR", String.join(", ", errors)));
    }
}
```

### Spring Security + JWT

```java
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/public/**").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
            .build();
    }
}
```

---

## ⚛️ Conventions Frontend (React/TypeScript)

### Composants

```tsx
interface ProductCardProps {
  product: Product;
  onAddToCart?: (product: Product) => void;
}

export const ProductCard: React.FC<ProductCardProps> = ({ 
  product, 
  onAddToCart 
}) => {
  const handleClick = () => {
    onAddToCart?.(product);
  };

  return (
    <div className="product-card">
      <h3>{product.name}</h3>
      <p className="price">{formatPrice(product.price)}</p>
      <button onClick={handleClick}>Ajouter au panier</button>
    </div>
  );
};
```

**Règles :**
- Functional components uniquement
- Props typées avec interface (suffixe `Props`)
- Export nommé (pas de default export)
- Nom du fichier = nom du composant

### Hooks personnalisés

```tsx
interface UseProductsOptions {
  page?: number;
  size?: number;
}

interface UseProductsResult {
  products: Product[];
  loading: boolean;
  error: Error | null;
  refetch: () => void;
}

export const useProducts = (options: UseProductsOptions = {}): UseProductsResult => {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchProducts = useCallback(async () => {
    try {
      setLoading(true);
      const data = await productService.findAll(options);
      setProducts(data.content);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  }, [options.page, options.size]);

  useEffect(() => {
    fetchProducts();
  }, [fetchProducts]);

  return { products, loading, error, refetch: fetchProducts };
};
```

**Règles :**
- Préfixer avec `use`
- Retourner un objet typé
- Gérer loading, error, data

### Services API

```tsx
const API_URL = import.meta.env.VITE_API_URL;

export const productService = {
  async findAll(params?: PaginationParams): Promise<Page<Product>> {
    const response = await fetch(`${API_URL}/products?${new URLSearchParams(params)}`);
    if (!response.ok) throw new Error('Failed to fetch products');
    return response.json();
  },

  async create(product: ProductRequest): Promise<Product> {
    const response = await fetch(`${API_URL}/products`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${getToken()}`,
      },
      body: JSON.stringify(product),
    });
    if (!response.ok) throw new Error('Failed to create product');
    return response.json();
  },
};
```

### Types

```tsx
// types/product.ts
export interface Product {
  id: string;
  name: string;
  price: number;
  createdAt: string;
}

export interface ProductRequest {
  name: string;
  price: number;
}

// types/common.ts
export interface Page<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;
  size: number;
}
```

### Authentification

```tsx
interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  login: (credentials: LoginRequest) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};
```

---

## 🐳 Conventions Docker

### Variables d'environnement

- Utiliser `.env` pour les variables locales (jamais commité)
- Documenter dans `.env.example`
- Préfixer les variables Vite avec `VITE_`

### Nommage des conteneurs

- Format : `app-{service}` ou `app-{service}-{env}`
- Exemples : `app-postgres`, `app-backend`, `app-frontend`

---

## ✅ Checklist pour nouveau code

### Backend
- [ ] Entité avec UUID et timestamps
- [ ] DTO Request/Response séparés
- [ ] Validation Bean Validation
- [ ] Service avec interface
- [ ] Tests unitaires
- [ ] Documentation OpenAPI

### Frontend
- [ ] Types TypeScript
- [ ] Props interface
- [ ] Gestion loading/error
- [ ] Responsive design
- [ ] Tests avec Testing Library

