---
name: backend-entity
description: Generate JPA entities for Spring Boot 3.4.x with Java 21. Use this when asked to create database entities, models, or domain objects for the backend.
---

# JPA Entity Generation

Generate JPA entities following project conventions for Spring Boot 3.4.x with Java 21 and PostgreSQL 16.

## Required Structure

```java
@Entity
@Table(name = "table_names")
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EntityName {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    // Business fields here

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(nullable = false)
    private Instant updatedAt;
}
```

## Naming Conventions

- Class name: PascalCase singular (`Product`, `User`, `OrderItem`)
- Table name: snake_case plural (`products`, `users`, `order_items`)
- Column names: snake_case (`created_at`, `first_name`)

## Required Elements

1. **ID**: Always use UUID with `@GeneratedValue(strategy = GenerationType.UUID)`
2. **Timestamps**: Always include `createdAt` (non-updatable) and `updatedAt`
3. **Auditing**: Use `@EntityListeners(AuditingEntityListener.class)`
4. **Lombok**: Use `@Data`, `@Builder`, `@NoArgsConstructor`, `@AllArgsConstructor`

## Type Mappings

| Java Type | PostgreSQL | Notes |
|-----------|------------|-------|
| `String` | `VARCHAR(255)` | Default |
| `String` + `@Lob` | `TEXT` | For long text |
| `BigDecimal` | `NUMERIC(precision, scale)` | For monetary values |
| `Instant` | `TIMESTAMP WITH TIME ZONE` | For timestamps |
| `LocalDate` | `DATE` | For dates only |
| `UUID` | `UUID` | Native PostgreSQL |
| `enum` | `VARCHAR` | With `@Enumerated(EnumType.STRING)` |

## Relationships

### ManyToOne (owning side)
```java
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "category_id", nullable = false)
private Category category;
```

### OneToMany (inverse side)
```java
@OneToMany(mappedBy = "category", cascade = CascadeType.ALL, orphanRemoval = true)
@Builder.Default
private List<Product> products = new ArrayList<>();
```

### ManyToMany
```java
@ManyToMany
@JoinTable(
    name = "product_tags",
    joinColumns = @JoinColumn(name = "product_id"),
    inverseJoinColumns = @JoinColumn(name = "tag_id")
)
@Builder.Default
private Set<Tag> tags = new HashSet<>();
```

## Indexes and Constraints

```java
@Table(
    name = "products",
    indexes = {
        @Index(name = "idx_product_name", columnList = "name"),
        @Index(name = "idx_product_category", columnList = "category_id")
    },
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_product_sku", columnNames = "sku")
    }
)
```

## User Entity for Authentication

For User entities implementing Spring Security:

```java
@Entity
@Table(name = "users")
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private Role role = Role.USER;

    @Column(nullable = false)
    @Builder.Default
    private boolean enabled = true;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(nullable = false)
    private Instant updatedAt;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }

    @Override
    public String getUsername() {
        return email;
    }
}
```

## Configuration Required

Enable JPA auditing:

```java
@Configuration
@EnableJpaAuditing
public class JpaConfig {
}
```

