---
name: backend-dto-mapper
description: Generate DTO mappers using MapStruct or manual mapping methods for Spring Boot 3.4.x. Use this when asked to create converters between entities and DTOs.
---

# DTO Mapper Generation

Generate mappers following project conventions for Spring Boot 3.4.x.

## Option 1: MapStruct (Recommended)

### Required Dependencies

```xml
<properties>
    <mapstruct.version>1.5.5.Final</mapstruct.version>
    <lombok-mapstruct-binding.version>0.2.0</lombok-mapstruct-binding.version>
</properties>

<dependencies>
    <dependency>
        <groupId>org.mapstruct</groupId>
        <artifactId>mapstruct</artifactId>
        <version>${mapstruct.version}</version>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <configuration>
                <annotationProcessorPaths>
                    <path>
                        <groupId>org.mapstruct</groupId>
                        <artifactId>mapstruct-processor</artifactId>
                        <version>${mapstruct.version}</version>
                    </path>
                    <path>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok</artifactId>
                        <version>${lombok.version}</version>
                    </path>
                    <path>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok-mapstruct-binding</artifactId>
                        <version>${lombok-mapstruct-binding.version}</version>
                    </path>
                </annotationProcessorPaths>
            </configuration>
        </plugin>
    </plugins>
</build>
```

### MapStruct Configuration

```java
@MapperConfig(
    componentModel = MappingConstants.ComponentModel.SPRING,
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE
)
public interface MapStructConfig {
}
```

### Basic Entity Mapper

```java
@Mapper(config = MapStructConfig.class)
public interface ProductMapper {

    ProductResponse toResponse(Product product);

    List<ProductResponse> toResponseList(List<Product> products);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Product toEntity(ProductRequest request);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateEntity(@MappingTarget Product product, ProductRequest request);
}
```

### Mapper with Relations

```java
@Mapper(config = MapStructConfig.class, uses = {CategoryMapper.class})
public interface ProductMapper {

    @Mapping(source = "category.id", target = "categoryId")
    @Mapping(source = "category.name", target = "categoryName")
    ProductResponse toResponse(Product product);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "category", ignore = true)
    Product toEntity(ProductRequest request);

    default Page<ProductResponse> toResponsePage(Page<Product> page) {
        return page.map(this::toResponse);
    }
}
```

### Mapper with Custom Methods

```java
@Mapper(config = MapStructConfig.class)
public interface OrderMapper {

    @Mapping(source = "user.id", target = "userId")
    @Mapping(source = "user.email", target = "userEmail")
    @Mapping(target = "itemCount", expression = "java(order.getItems().size())")
    @Mapping(target = "totalFormatted", expression = "java(formatPrice(order.getTotal()))")
    OrderResponse toResponse(Order order);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "status", constant = "PENDING")
    @Mapping(target = "items", ignore = true)
    Order toEntity(CreateOrderRequest request);

    default String formatPrice(BigDecimal price) {
        if (price == null) return null;
        return NumberFormat.getCurrencyInstance(Locale.FRANCE).format(price);
    }
}
```

### Mapper with Enums

```java
@Mapper(config = MapStructConfig.class)
public interface UserMapper {

    @Mapping(target = "role", source = "role")
    UserResponse toResponse(User user);

    @ValueMapping(source = "ADMIN", target = "Administrator")
    @ValueMapping(source = "USER", target = "Standard User")
    @ValueMapping(source = MappingConstants.ANY_REMAINING, target = "Unknown")
    String roleToDisplayName(Role role);
}
```

### Mapper with @AfterMapping

```java
@Mapper(config = MapStructConfig.class)
public abstract class ProductMapper {

    @Autowired
    private PriceService priceService;

    @Mapping(target = "discountedPrice", ignore = true)
    public abstract ProductResponse toResponse(Product product);

    @AfterMapping
    protected void calculateDiscountedPrice(Product product, @MappingTarget ProductResponse.ProductResponseBuilder response) {
        var discount = priceService.calculateDiscount(product);
        response.discountedPrice(product.getPrice().subtract(discount));
    }
}
```

---

## Option 2: Manual Mapping (Without MapStruct)

### Mapper Interface + Implementation

```java
public interface ProductMapper {
    ProductResponse toResponse(Product product);
    List<ProductResponse> toResponseList(List<Product> products);
    Page<ProductResponse> toResponsePage(Page<Product> products);
    Product toEntity(ProductRequest request);
    void updateEntity(Product product, ProductRequest request);
}

@Component
@RequiredArgsConstructor
public class ProductMapperImpl implements ProductMapper {

    @Override
    public ProductResponse toResponse(Product product) {
        if (product == null) return null;
        
        return new ProductResponse(
            product.getId(),
            product.getName(),
            product.getPrice(),
            product.getDescription(),
            product.getCategory() != null ? product.getCategory().getId() : null,
            product.getCategory() != null ? product.getCategory().getName() : null,
            product.getCreatedAt(),
            product.getUpdatedAt()
        );
    }

    @Override
    public List<ProductResponse> toResponseList(List<Product> products) {
        if (products == null) return List.of();
        return products.stream()
            .map(this::toResponse)
            .toList();
    }

    @Override
    public Page<ProductResponse> toResponsePage(Page<Product> products) {
        return products.map(this::toResponse);
    }

    @Override
    public Product toEntity(ProductRequest request) {
        if (request == null) return null;
        
        return Product.builder()
            .name(request.name())
            .price(request.price())
            .description(request.description())
            .build();
    }

    @Override
    public void updateEntity(Product product, ProductRequest request) {
        if (request == null) return;
        
        product.setName(request.name());
        product.setPrice(request.price());
        if (request.description() != null) {
            product.setDescription(request.description());
        }
    }
}
```

### Static Mapper Methods (Alternative)

```java
public final class ProductMapper {

    private ProductMapper() {
        // Utility class
    }

    public static ProductResponse toResponse(Product product) {
        if (product == null) return null;
        
        return new ProductResponse(
            product.getId(),
            product.getName(),
            product.getPrice(),
            product.getCreatedAt()
        );
    }

    public static Product toEntity(ProductRequest request) {
        if (request == null) return null;
        
        return Product.builder()
            .name(request.name())
            .price(request.price())
            .build();
    }
}
```

### Inline Mapping in Service (Simple cases)

```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
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
        var product = Product.builder()
            .name(request.name())
            .price(request.price())
            .description(request.description())
            .build();
        return toResponse(productRepository.save(product));
    }

    // Private mapping methods
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

---

## Complex Mapping Examples

### List Response with Summary

```java
public record ProductListResponse(
    List<ProductResponse> items,
    int count,
    BigDecimal totalValue,
    Map<String, Long> countByCategory
) {
    public static ProductListResponse of(List<Product> products) {
        var items = products.stream()
            .map(ProductMapper::toResponse)
            .toList();
        
        var totalValue = products.stream()
            .map(Product::getPrice)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        var countByCategory = products.stream()
            .filter(p -> p.getCategory() != null)
            .collect(Collectors.groupingBy(
                p -> p.getCategory().getName(),
                Collectors.counting()
            ));
        
        return new ProductListResponse(items, items.size(), totalValue, countByCategory);
    }
}
```

### Nested Object Mapping

```java
@Mapper(config = MapStructConfig.class)
public interface OrderMapper {

    @Mapping(source = "user", target = "customer")
    @Mapping(source = "items", target = "orderItems")
    OrderDetailResponse toDetailResponse(Order order);

    @Mapping(source = "id", target = "userId")
    @Mapping(target = "fullName", expression = "java(user.getFirstName() + ' ' + user.getLastName())")
    CustomerInfo toCustomerInfo(User user);

    @Mapping(source = "product.id", target = "productId")
    @Mapping(source = "product.name", target = "productName")
    @Mapping(target = "lineTotal", expression = "java(item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))")
    OrderItemResponse toOrderItemResponse(OrderItem item);
}
```

### Bidirectional Mapping

```java
@Mapper(config = MapStructConfig.class)
public interface CategoryMapper {

    // Avoid circular reference - don't map products
    @Mapping(target = "productCount", expression = "java(category.getProducts() != null ? category.getProducts().size() : 0)")
    CategoryResponse toResponse(Category category);

    // Full mapping with products (use carefully)
    @Named("withProducts")
    @Mapping(source = "products", target = "products")
    CategoryDetailResponse toDetailResponse(Category category);
}
```

---

## Mapper Package Structure

```
src/main/java/com/example/app/
├── dto/
│   ├── request/
│   │   └── ProductRequest.java
│   └── response/
│       └── ProductResponse.java
└── mapper/
    ├── MapStructConfig.java
    ├── ProductMapper.java
    ├── CategoryMapper.java
    └── UserMapper.java
```

## Usage in Service

```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ProductMapper productMapper;

    @Override
    public Page<ProductResponse> findAll(Pageable pageable) {
        return productMapper.toResponsePage(productRepository.findAll(pageable));
    }

    @Override
    public ProductResponse findById(UUID id) {
        return productRepository.findById(id)
            .map(productMapper::toResponse)
            .orElseThrow(() -> new ResourceNotFoundException("Product", id));
    }

    @Override
    @Transactional
    public ProductResponse create(ProductRequest request) {
        var product = productMapper.toEntity(request);
        
        if (request.categoryId() != null) {
            var category = categoryRepository.findById(request.categoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category", request.categoryId()));
            product.setCategory(category);
        }
        
        return productMapper.toResponse(productRepository.save(product));
    }

    @Override
    @Transactional
    public ProductResponse update(UUID id, ProductRequest request) {
        var product = productRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Product", id));
        
        productMapper.updateEntity(product, request);
        
        return productMapper.toResponse(productRepository.save(product));
    }
}
```

