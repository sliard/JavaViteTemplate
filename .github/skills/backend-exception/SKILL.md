---
name: backend-exception
description: Generate custom exceptions and global exception handlers for Spring Boot 3.4.x. Use this when asked to create business exceptions, error handling, or API error responses.
---

# Exception Handling Generation

Generate exceptions and handlers following project conventions for Spring Boot 3.4.x.

## Error Response Structure

```java
public record ErrorResponse(
    Instant timestamp,
    int status,
    String error,
    String code,
    String message,
    List<FieldError> details,
    String path
) {
    public record FieldError(String field, String message) {}

    public static ErrorResponse of(HttpStatus status, String code, String message, String path) {
        return new ErrorResponse(
            Instant.now(),
            status.value(),
            status.getReasonPhrase(),
            code,
            message,
            List.of(),
            path
        );
    }

    public static ErrorResponse withDetails(HttpStatus status, String code, String message, 
                                            List<FieldError> details, String path) {
        return new ErrorResponse(
            Instant.now(),
            status.value(),
            status.getReasonPhrase(),
            code,
            message,
            details,
            path
        );
    }
}
```

## Base Exception Classes

### Abstract Business Exception

```java
public abstract class BusinessException extends RuntimeException {
    
    private final String code;
    private final HttpStatus status;

    protected BusinessException(String message, String code, HttpStatus status) {
        super(message);
        this.code = code;
        this.status = status;
    }

    protected BusinessException(String message, String code, HttpStatus status, Throwable cause) {
        super(message, cause);
        this.code = code;
        this.status = status;
    }

    public String getCode() {
        return code;
    }

    public HttpStatus getStatus() {
        return status;
    }
}
```

### Resource Not Found Exception

```java
public class ResourceNotFoundException extends BusinessException {

    private static final String DEFAULT_CODE = "RESOURCE_NOT_FOUND";

    public ResourceNotFoundException(String resourceName, Object id) {
        super(
            String.format("%s not found with id: %s", resourceName, id),
            DEFAULT_CODE,
            HttpStatus.NOT_FOUND
        );
    }

    public ResourceNotFoundException(String message) {
        super(message, DEFAULT_CODE, HttpStatus.NOT_FOUND);
    }
}
```

### Resource Already Exists Exception

```java
public class ResourceAlreadyExistsException extends BusinessException {

    private static final String DEFAULT_CODE = "RESOURCE_ALREADY_EXISTS";

    public ResourceAlreadyExistsException(String resourceName, String field, Object value) {
        super(
            String.format("%s already exists with %s: %s", resourceName, field, value),
            DEFAULT_CODE,
            HttpStatus.CONFLICT
        );
    }
}
```

### Invalid Operation Exception

```java
public class InvalidOperationException extends BusinessException {

    private static final String DEFAULT_CODE = "INVALID_OPERATION";

    public InvalidOperationException(String message) {
        super(message, DEFAULT_CODE, HttpStatus.UNPROCESSABLE_ENTITY);
    }

    public InvalidOperationException(String message, String code) {
        super(message, code, HttpStatus.UNPROCESSABLE_ENTITY);
    }
}
```

### Access Denied Exception

```java
public class AccessDeniedException extends BusinessException {

    private static final String DEFAULT_CODE = "ACCESS_DENIED";

    public AccessDeniedException(String message) {
        super(message, DEFAULT_CODE, HttpStatus.FORBIDDEN);
    }

    public AccessDeniedException() {
        super("You don't have permission to access this resource", DEFAULT_CODE, HttpStatus.FORBIDDEN);
    }
}
```

## Domain-Specific Exceptions

### Example: Order Exceptions

```java
public class OrderException extends BusinessException {

    protected OrderException(String message, String code, HttpStatus status) {
        super(message, code, status);
    }
}

public class OrderNotFoundException extends OrderException {

    public OrderNotFoundException(UUID orderId) {
        super(
            String.format("Order not found: %s", orderId),
            "ORDER_NOT_FOUND",
            HttpStatus.NOT_FOUND
        );
    }
}

public class OrderAlreadyCancelledException extends OrderException {

    public OrderAlreadyCancelledException(UUID orderId) {
        super(
            String.format("Order %s is already cancelled", orderId),
            "ORDER_ALREADY_CANCELLED",
            HttpStatus.CONFLICT
        );
    }
}

public class OrderCannotBeCancelledException extends OrderException {

    public OrderCannotBeCancelledException(UUID orderId, String reason) {
        super(
            String.format("Order %s cannot be cancelled: %s", orderId, reason),
            "ORDER_CANNOT_BE_CANCELLED",
            HttpStatus.UNPROCESSABLE_ENTITY
        );
    }
}

public class InsufficientStockException extends OrderException {

    public InsufficientStockException(UUID productId, int requested, int available) {
        super(
            String.format("Insufficient stock for product %s: requested %d, available %d", 
                productId, requested, available),
            "INSUFFICIENT_STOCK",
            HttpStatus.UNPROCESSABLE_ENTITY
        );
    }
}
```

### Example: Authentication Exceptions

```java
public class AuthenticationException extends BusinessException {

    protected AuthenticationException(String message, String code, HttpStatus status) {
        super(message, code, status);
    }
}

public class InvalidCredentialsException extends AuthenticationException {

    public InvalidCredentialsException() {
        super(
            "Invalid email or password",
            "INVALID_CREDENTIALS",
            HttpStatus.UNAUTHORIZED
        );
    }
}

public class TokenExpiredException extends AuthenticationException {

    public TokenExpiredException() {
        super(
            "Token has expired",
            "TOKEN_EXPIRED",
            HttpStatus.UNAUTHORIZED
        );
    }
}

public class InvalidTokenException extends AuthenticationException {

    public InvalidTokenException() {
        super(
            "Invalid token",
            "INVALID_TOKEN",
            HttpStatus.UNAUTHORIZED
        );
    }
}

public class UserDisabledException extends AuthenticationException {

    public UserDisabledException() {
        super(
            "User account is disabled",
            "USER_DISABLED",
            HttpStatus.FORBIDDEN
        );
    }
}
```

## Global Exception Handler

```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    // Business exceptions
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(
            BusinessException ex, HttpServletRequest request) {
        
        log.warn("Business exception: {} - {}", ex.getCode(), ex.getMessage());
        
        return ResponseEntity
            .status(ex.getStatus())
            .body(ErrorResponse.of(
                ex.getStatus(),
                ex.getCode(),
                ex.getMessage(),
                request.getRequestURI()
            ));
    }

    // Validation errors
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(
            MethodArgumentNotValidException ex, HttpServletRequest request) {
        
        var fieldErrors = ex.getBindingResult().getFieldErrors().stream()
            .map(e -> new ErrorResponse.FieldError(e.getField(), e.getDefaultMessage()))
            .toList();
        
        log.warn("Validation error: {}", fieldErrors);
        
        return ResponseEntity
            .badRequest()
            .body(ErrorResponse.withDetails(
                HttpStatus.BAD_REQUEST,
                "VALIDATION_ERROR",
                "Validation failed",
                fieldErrors,
                request.getRequestURI()
            ));
    }

    // Constraint violations (path variables, request params)
    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ErrorResponse> handleConstraintViolation(
            ConstraintViolationException ex, HttpServletRequest request) {
        
        var fieldErrors = ex.getConstraintViolations().stream()
            .map(v -> new ErrorResponse.FieldError(
                v.getPropertyPath().toString(), 
                v.getMessage()
            ))
            .toList();
        
        return ResponseEntity
            .badRequest()
            .body(ErrorResponse.withDetails(
                HttpStatus.BAD_REQUEST,
                "CONSTRAINT_VIOLATION",
                "Constraint violation",
                fieldErrors,
                request.getRequestURI()
            ));
    }

    // Missing request params
    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<ErrorResponse> handleMissingParam(
            MissingServletRequestParameterException ex, HttpServletRequest request) {
        
        return ResponseEntity
            .badRequest()
            .body(ErrorResponse.of(
                HttpStatus.BAD_REQUEST,
                "MISSING_PARAMETER",
                String.format("Missing required parameter: %s", ex.getParameterName()),
                request.getRequestURI()
            ));
    }

    // Invalid path variable
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ErrorResponse> handleTypeMismatch(
            MethodArgumentTypeMismatchException ex, HttpServletRequest request) {
        
        return ResponseEntity
            .badRequest()
            .body(ErrorResponse.of(
                HttpStatus.BAD_REQUEST,
                "INVALID_PARAMETER",
                String.format("Invalid value for parameter '%s': %s", 
                    ex.getName(), ex.getValue()),
                request.getRequestURI()
            ));
    }

    // Invalid JSON
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ErrorResponse> handleNotReadable(
            HttpMessageNotReadableException ex, HttpServletRequest request) {
        
        return ResponseEntity
            .badRequest()
            .body(ErrorResponse.of(
                HttpStatus.BAD_REQUEST,
                "INVALID_JSON",
                "Invalid JSON in request body",
                request.getRequestURI()
            ));
    }

    // Method not allowed
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ErrorResponse> handleMethodNotAllowed(
            HttpRequestMethodNotSupportedException ex, HttpServletRequest request) {
        
        return ResponseEntity
            .status(HttpStatus.METHOD_NOT_ALLOWED)
            .body(ErrorResponse.of(
                HttpStatus.METHOD_NOT_ALLOWED,
                "METHOD_NOT_ALLOWED",
                String.format("Method %s not allowed", ex.getMethod()),
                request.getRequestURI()
            ));
    }

    // Spring Security - Access denied
    @ExceptionHandler(org.springframework.security.access.AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleAccessDenied(
            org.springframework.security.access.AccessDeniedException ex, 
            HttpServletRequest request) {
        
        return ResponseEntity
            .status(HttpStatus.FORBIDDEN)
            .body(ErrorResponse.of(
                HttpStatus.FORBIDDEN,
                "ACCESS_DENIED",
                "Access denied",
                request.getRequestURI()
            ));
    }

    // JPA - Entity not found
    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleEntityNotFound(
            EntityNotFoundException ex, HttpServletRequest request) {
        
        return ResponseEntity
            .status(HttpStatus.NOT_FOUND)
            .body(ErrorResponse.of(
                HttpStatus.NOT_FOUND,
                "NOT_FOUND",
                ex.getMessage(),
                request.getRequestURI()
            ));
    }

    // Data integrity (unique constraint, foreign key)
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDataIntegrity(
            DataIntegrityViolationException ex, HttpServletRequest request) {
        
        log.error("Data integrity violation", ex);
        
        String message = "Data integrity violation";
        String code = "DATA_INTEGRITY_ERROR";
        
        if (ex.getCause() instanceof ConstraintViolationException) {
            message = "Duplicate entry or constraint violation";
            code = "CONSTRAINT_ERROR";
        }
        
        return ResponseEntity
            .status(HttpStatus.CONFLICT)
            .body(ErrorResponse.of(
                HttpStatus.CONFLICT,
                code,
                message,
                request.getRequestURI()
            ));
    }

    // Catch-all for unexpected errors
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(
            Exception ex, HttpServletRequest request) {
        
        log.error("Unexpected error", ex);
        
        return ResponseEntity
            .status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(ErrorResponse.of(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "INTERNAL_ERROR",
                "An unexpected error occurred",
                request.getRequestURI()
            ));
    }
}
```

## Exception Package Structure

```
src/main/java/com/example/app/
└── exception/
    ├── ErrorResponse.java
    ├── GlobalExceptionHandler.java
    ├── BusinessException.java
    ├── ResourceNotFoundException.java
    ├── ResourceAlreadyExistsException.java
    ├── InvalidOperationException.java
    ├── AccessDeniedException.java
    └── auth/
        ├── AuthenticationException.java
        ├── InvalidCredentialsException.java
        ├── TokenExpiredException.java
        └── InvalidTokenException.java
```

## Usage in Services

```java
@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;

    @Override
    public ProductResponse findById(UUID id) {
        return productRepository.findById(id)
            .map(this::toResponse)
            .orElseThrow(() -> new ResourceNotFoundException("Product", id));
    }

    @Override
    @Transactional
    public ProductResponse create(ProductRequest request) {
        if (productRepository.existsByName(request.name())) {
            throw new ResourceAlreadyExistsException("Product", "name", request.name());
        }
        // ...
    }

    @Override
    @Transactional
    public void publish(UUID id) {
        var product = productRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Product", id));
        
        if (product.getStock() <= 0) {
            throw new InvalidOperationException("Cannot publish product with no stock");
        }
        // ...
    }
}
```

## Required Imports

```java
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.dao.DataIntegrityViolationException;
import jakarta.persistence.EntityNotFoundException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import java.time.Instant;
import java.util.List;
```

