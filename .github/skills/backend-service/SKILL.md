---
name: backend-service
description: Generate services and repositories for Spring Boot 3.4.x with Spring Data JPA. Use this when asked to create business logic, service layers, or data access repositories.
---

# Service and Repository Generation

Generate services and repositories following project conventions for Spring Boot 3.4.x.

## Repository Pattern

```java
@Repository
public interface EntityRepository extends JpaRepository<Entity, UUID>, 
                                          JpaSpecificationExecutor<Entity> {
    // Custom query methods
}
```

### Common Query Methods

```java
// Find by field
Optional<Product> findByName(String name);

// Check existence
boolean existsByEmail(String email);

// Find with conditions
List<Product> findByCategoryAndPriceGreaterThan(Category category, BigDecimal price);

// Search (LIKE)
List<Product> findByNameContainingIgnoreCase(String name);

// Pagination
Page<Product> findByCategory(Category category, Pageable pageable);

// Custom JPQL
@Query("SELECT p FROM Product p WHERE p.category.id = :categoryId")
List<Product> findByCategoryId(@Param("categoryId") UUID categoryId);
```

## Service Pattern

### Interface + Implementation

```java
// Interface
public interface ProductService {
    Page<ProductResponse> findAll(Pageable pageable);
    ProductResponse findById(UUID id);
    ProductResponse create(ProductRequest request);
    ProductResponse update(UUID id, ProductRequest request);
    void delete(UUID id);
}

// Implementation
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
    public ProductResponse findById(UUID id) {
        return productRepository.findById(id)
            .map(this::toResponse)
            .orElseThrow(() -> new EntityNotFoundException("Product not found: " + id));
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

    @Override
    @Transactional
    public ProductResponse update(UUID id, ProductRequest request) {
        var product = productRepository.findById(id)
            .orElseThrow(() -> new EntityNotFoundException("Product not found: " + id));
        
        product.setName(request.name());
        product.setPrice(request.price());
        
        return toResponse(productRepository.save(product));
    }

    @Override
    @Transactional
    public void delete(UUID id) {
        if (!productRepository.existsById(id)) {
            throw new EntityNotFoundException("Product not found: " + id);
        }
        productRepository.deleteById(id);
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

## DTOs (Records)

```java
public record ProductRequest(
    @NotBlank(message = "Name is required")
    @Size(max = 255)
    String name,

    @NotNull(message = "Price is required")
    @Positive(message = "Price must be positive")
    BigDecimal price
) {}

public record ProductResponse(
    UUID id,
    String name,
    BigDecimal price,
    Instant createdAt
) {}
```

## Transaction Guidelines

1. Class-level: `@Transactional(readOnly = true)` for read-heavy services
2. Method-level: `@Transactional` on methods that modify data
3. Keep transactions short
4. Avoid lazy loading issues by fetching required data

## Exception Handling

Use custom exceptions:

```java
public class EntityNotFoundException extends RuntimeException {
    public EntityNotFoundException(String message) {
        super(message);
    }
}
```

Handle in `@RestControllerAdvice`:

```java
@ExceptionHandler(EntityNotFoundException.class)
public ResponseEntity<ErrorResponse> handleNotFound(EntityNotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND)
        .body(new ErrorResponse("NOT_FOUND", ex.getMessage()));
}
```

