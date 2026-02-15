---
name: backend-testing
description: Generate unit and integration tests for Spring Boot 3.4.x with JUnit 5, Mockito, and Testcontainers. Use this when asked to create tests for services, controllers, or repositories.
---

# Backend Testing Generation

Generate tests following project conventions for Spring Boot 3.4.x with JUnit 5, Mockito, AssertJ, and Testcontainers.

## Required Dependencies

```xml
<dependencies>
    <!-- Test -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-test</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- Testcontainers -->
    <dependency>
        <groupId>org.testcontainers</groupId>
        <artifactId>junit-jupiter</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.testcontainers</groupId>
        <artifactId>postgresql</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Test Naming Conventions

- Class: `{ClassName}Test` for unit tests, `{ClassName}IT` for integration tests
- Methods: `should{ExpectedBehavior}_when{Condition}`
- Use descriptive names that explain the test scenario

## Service Unit Tests

```java
@ExtendWith(MockitoExtension.class)
class ProductServiceImplTest {

    @Mock
    private ProductRepository productRepository;

    @InjectMocks
    private ProductServiceImpl productService;

    @Nested
    @DisplayName("findById")
    class FindById {

        @Test
        @DisplayName("should return product when id exists")
        void shouldReturnProduct_whenIdExists() {
            // Given
            var id = UUID.randomUUID();
            var product = Product.builder()
                .id(id)
                .name("Test Product")
                .price(BigDecimal.valueOf(99.99))
                .build();
            when(productRepository.findById(id)).thenReturn(Optional.of(product));

            // When
            var result = productService.findById(id);

            // Then
            assertThat(result).isNotNull();
            assertThat(result.id()).isEqualTo(id);
            assertThat(result.name()).isEqualTo("Test Product");
            verify(productRepository).findById(id);
        }

        @Test
        @DisplayName("should throw EntityNotFoundException when id does not exist")
        void shouldThrowException_whenIdNotFound() {
            // Given
            var id = UUID.randomUUID();
            when(productRepository.findById(id)).thenReturn(Optional.empty());

            // When/Then
            assertThatThrownBy(() -> productService.findById(id))
                .isInstanceOf(EntityNotFoundException.class)
                .hasMessageContaining(id.toString());
        }
    }

    @Nested
    @DisplayName("create")
    class Create {

        @Test
        @DisplayName("should create and return product")
        void shouldCreateProduct_whenValidRequest() {
            // Given
            var request = new ProductRequest("New Product", BigDecimal.valueOf(49.99), "Description");
            var savedProduct = Product.builder()
                .id(UUID.randomUUID())
                .name(request.name())
                .price(request.price())
                .build();
            when(productRepository.save(any(Product.class))).thenReturn(savedProduct);

            // When
            var result = productService.create(request);

            // Then
            assertThat(result.name()).isEqualTo("New Product");
            verify(productRepository).save(argThat(p -> p.getName().equals("New Product")));
        }
    }

    @Nested
    @DisplayName("delete")
    class Delete {

        @Test
        @DisplayName("should delete product when exists")
        void shouldDeleteProduct_whenExists() {
            // Given
            var id = UUID.randomUUID();
            when(productRepository.existsById(id)).thenReturn(true);

            // When
            productService.delete(id);

            // Then
            verify(productRepository).deleteById(id);
        }

        @Test
        @DisplayName("should throw exception when product not found")
        void shouldThrowException_whenNotFound() {
            // Given
            var id = UUID.randomUUID();
            when(productRepository.existsById(id)).thenReturn(false);

            // When/Then
            assertThatThrownBy(() -> productService.delete(id))
                .isInstanceOf(EntityNotFoundException.class);
        }
    }
}
```

## Controller Integration Tests

```java
@WebMvcTest(ProductController.class)
@Import({SecurityConfig.class, JwtAuthenticationFilter.class})
class ProductControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private ProductService productService;

    @MockBean
    private JwtService jwtService;

    @MockBean
    private UserDetailsService userDetailsService;

    @Nested
    @DisplayName("GET /api/products")
    class GetAll {

        @Test
        @DisplayName("should return page of products")
        void shouldReturnProducts() throws Exception {
            // Given
            var products = List.of(
                new ProductResponse(UUID.randomUUID(), "Product 1", BigDecimal.TEN, Instant.now()),
                new ProductResponse(UUID.randomUUID(), "Product 2", BigDecimal.valueOf(20), Instant.now())
            );
            when(productService.findAll(any(Pageable.class))).thenReturn(new PageImpl<>(products));

            // When/Then
            mockMvc.perform(get("/api/products")
                    .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray())
                .andExpect(jsonPath("$.content", hasSize(2)))
                .andExpect(jsonPath("$.content[0].name").value("Product 1"));
        }
    }

    @Nested
    @DisplayName("GET /api/products/{id}")
    class GetById {

        @Test
        @DisplayName("should return product when found")
        void shouldReturnProduct_whenFound() throws Exception {
            // Given
            var id = UUID.randomUUID();
            var product = new ProductResponse(id, "Test Product", BigDecimal.valueOf(99.99), Instant.now());
            when(productService.findById(id)).thenReturn(product);

            // When/Then
            mockMvc.perform(get("/api/products/{id}", id))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(id.toString()))
                .andExpect(jsonPath("$.name").value("Test Product"));
        }

        @Test
        @DisplayName("should return 404 when not found")
        void shouldReturn404_whenNotFound() throws Exception {
            // Given
            var id = UUID.randomUUID();
            when(productService.findById(id)).thenThrow(new EntityNotFoundException("Product not found"));

            // When/Then
            mockMvc.perform(get("/api/products/{id}", id))
                .andExpect(status().isNotFound());
        }
    }

    @Nested
    @DisplayName("POST /api/products")
    class Create {

        @Test
        @WithMockUser(roles = "ADMIN")
        @DisplayName("should create product when admin")
        void shouldCreateProduct_whenAdmin() throws Exception {
            // Given
            var request = new ProductRequest("New Product", BigDecimal.valueOf(49.99), "Description");
            var response = new ProductResponse(UUID.randomUUID(), request.name(), request.price(), Instant.now());
            when(productService.create(any(ProductRequest.class))).thenReturn(response);

            // When/Then
            mockMvc.perform(post("/api/products")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("New Product"));
        }

        @Test
        @DisplayName("should return 401 when not authenticated")
        void shouldReturn401_whenNotAuthenticated() throws Exception {
            // Given
            var request = new ProductRequest("New Product", BigDecimal.valueOf(49.99), "Description");

            // When/Then
            mockMvc.perform(post("/api/products")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized());
        }

        @Test
        @WithMockUser(roles = "USER")
        @DisplayName("should return 403 when not admin")
        void shouldReturn403_whenNotAdmin() throws Exception {
            // Given
            var request = new ProductRequest("New Product", BigDecimal.valueOf(49.99), "Description");

            // When/Then
            mockMvc.perform(post("/api/products")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden());
        }

        @Test
        @WithMockUser(roles = "ADMIN")
        @DisplayName("should return 400 when validation fails")
        void shouldReturn400_whenValidationFails() throws Exception {
            // Given - missing required fields
            var request = new ProductRequest("", null, null);

            // When/Then
            mockMvc.perform(post("/api/products")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
        }
    }
}
```

## Repository Tests with Testcontainers

```java
@DataJpaTest
@Testcontainers
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class ProductRepositoryTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private TestEntityManager entityManager;

    @BeforeEach
    void setUp() {
        productRepository.deleteAll();
    }

    @Nested
    @DisplayName("findByName")
    class FindByName {

        @Test
        @DisplayName("should find product by exact name")
        void shouldFindByName() {
            // Given
            var product = Product.builder()
                .name("Test Product")
                .price(BigDecimal.valueOf(99.99))
                .build();
            entityManager.persistAndFlush(product);

            // When
            var result = productRepository.findByName("Test Product");

            // Then
            assertThat(result).isPresent();
            assertThat(result.get().getName()).isEqualTo("Test Product");
        }

        @Test
        @DisplayName("should return empty when not found")
        void shouldReturnEmpty_whenNotFound() {
            // When
            var result = productRepository.findByName("Nonexistent");

            // Then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("findByPriceBetween")
    class FindByPriceBetween {

        @Test
        @DisplayName("should find products in price range")
        void shouldFindInPriceRange() {
            // Given
            entityManager.persist(Product.builder().name("Cheap").price(BigDecimal.valueOf(10)).build());
            entityManager.persist(Product.builder().name("Medium").price(BigDecimal.valueOf(50)).build());
            entityManager.persist(Product.builder().name("Expensive").price(BigDecimal.valueOf(100)).build());
            entityManager.flush();

            // When
            var result = productRepository.findByPriceBetween(
                BigDecimal.valueOf(20), 
                BigDecimal.valueOf(80)
            );

            // Then
            assertThat(result).hasSize(1);
            assertThat(result.get(0).getName()).isEqualTo("Medium");
        }
    }
}
```

## Full Integration Tests

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
@AutoConfigureMockMvc
class ProductIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        productRepository.deleteAll();
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    @DisplayName("should create and retrieve product")
    void shouldCreateAndRetrieveProduct() throws Exception {
        // Create
        var request = new ProductRequest("Integration Test Product", BigDecimal.valueOf(199.99), "Test Description");
        var createResult = mockMvc.perform(post("/api/products")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andReturn();

        var created = objectMapper.readValue(
            createResult.getResponse().getContentAsString(), 
            ProductResponse.class
        );

        // Retrieve
        mockMvc.perform(get("/api/products/{id}", created.id()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("Integration Test Product"))
            .andExpect(jsonPath("$.price").value(199.99));

        // Verify in database
        assertThat(productRepository.findById(created.id())).isPresent();
    }
}
```

## Test Utilities

### Test Data Builders

```java
public class ProductTestData {

    public static Product.ProductBuilder aProduct() {
        return Product.builder()
            .id(UUID.randomUUID())
            .name("Test Product")
            .price(BigDecimal.valueOf(99.99))
            .description("Test Description")
            .createdAt(Instant.now())
            .updatedAt(Instant.now());
    }

    public static ProductRequest aProductRequest() {
        return new ProductRequest("Test Product", BigDecimal.valueOf(99.99), "Test Description");
    }

    public static ProductResponse aProductResponse() {
        return new ProductResponse(
            UUID.randomUUID(),
            "Test Product",
            BigDecimal.valueOf(99.99),
            Instant.now()
        );
    }
}
```

### Base Test Configuration

```java
@TestConfiguration
public class TestConfig {

    @Bean
    public Clock clock() {
        return Clock.fixed(Instant.parse("2024-01-15T10:00:00Z"), ZoneId.of("UTC"));
    }
}
```

## Import Statements

```java
// JUnit 5
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;

// Mockito
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.mockito.Mockito.*;
import static org.mockito.ArgumentMatchers.*;

// AssertJ
import static org.assertj.core.api.Assertions.*;

// Spring Test
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

// Testcontainers
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
```

