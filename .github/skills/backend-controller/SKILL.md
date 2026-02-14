---
name: backend-controller
description: Generate REST controllers for Spring Boot 3.4.x with OpenAPI documentation. Use this when asked to create API endpoints, REST controllers, or HTTP handlers.
---

# REST Controller Generation

Generate REST controllers following project conventions for Spring Boot 3.4.x.

## Controller Structure

```java
@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
@Tag(name = "Products", description = "Product management")
public class ProductController {

    private final ProductService productService;

    @GetMapping
    @Operation(summary = "List all products")
    public ResponseEntity<Page<ProductResponse>> findAll(Pageable pageable) {
        return ResponseEntity.ok(productService.findAll(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get product by ID")
    public ResponseEntity<ProductResponse> findById(@PathVariable UUID id) {
        return ResponseEntity.ok(productService.findById(id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a product")
    public ProductResponse create(@Valid @RequestBody ProductRequest request) {
        return productService.create(request);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update a product")
    public ResponseEntity<ProductResponse> update(
            @PathVariable UUID id,
            @Valid @RequestBody ProductRequest request) {
        return ResponseEntity.ok(productService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a product")
    public void delete(@PathVariable UUID id) {
        productService.delete(id);
    }
}
```

## URL Conventions

- Prefix: `/api/`
- Resource names: plural, lowercase (`/api/products`, `/api/users`)
- Nested resources: `/api/categories/{categoryId}/products`
- Actions: POST to `/api/products/{id}/publish`

## HTTP Methods and Status Codes

| Action | Method | URL | Success Status |
|--------|--------|-----|----------------|
| List | GET | /api/products | 200 OK |
| Get one | GET | /api/products/{id} | 200 OK |
| Create | POST | /api/products | 201 Created |
| Update | PUT | /api/products/{id} | 200 OK |
| Partial update | PATCH | /api/products/{id} | 200 OK |
| Delete | DELETE | /api/products/{id} | 204 No Content |

## Request Parameters

### Query Parameters
```java
@GetMapping
public Page<ProductResponse> findAll(
    @RequestParam(required = false) String name,
    @RequestParam(required = false) UUID categoryId,
    @RequestParam(required = false) BigDecimal minPrice,
    Pageable pageable
) { ... }
```

### Path Variables
```java
@GetMapping("/{id}")
public ProductResponse findById(@PathVariable UUID id) { ... }
```

### Request Body
```java
@PostMapping
public ProductResponse create(@Valid @RequestBody ProductRequest request) { ... }
```

## Pagination

Automatic via Spring Data:
```
GET /api/products?page=0&size=20&sort=name,asc
```

Response format includes `content`, `totalElements`, `totalPages`, etc.

## OpenAPI Documentation

```java
@Operation(
    summary = "Short description",
    description = "Detailed description"
)
@ApiResponse(responseCode = "200", description = "Success")
@ApiResponse(responseCode = "404", description = "Not found")
```

## Security with @PreAuthorize

```java
@GetMapping
@PreAuthorize("hasRole('USER')")
public List<ProductResponse> findAll() { ... }

@DeleteMapping("/{id}")
@PreAuthorize("hasRole('ADMIN')")
public void delete(@PathVariable UUID id) { ... }
```

## Access Current User

```java
@GetMapping("/me")
public UserResponse getCurrentUser(@AuthenticationPrincipal User user) {
    return userService.toResponse(user);
}
```

## Global Exception Handler

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

