---
name: backend-security
description: Configure Spring Security 6.x with JWT authentication for Spring Boot 3.4.x. Use this when asked to set up authentication, JWT tokens, login/register endpoints, or secure API endpoints.
---

# Spring Security + JWT Configuration

Configure JWT-based authentication for Spring Boot 3.4.x with Spring Security 6.x.

## Dependencies (pom.xml)

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.5</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.5</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.5</version>
    <scope>runtime</scope>
</dependency>
```

## Configuration Properties (application.yml)

```yaml
jwt:
  secret: ${JWT_SECRET:your-256-bit-secret-key-change-in-production}
  expiration-ms: ${JWT_EXPIRATION_MS:86400000}
  refresh-expiration-ms: ${JWT_REFRESH_EXPIRATION_MS:604800000}
```

## Implementation Components

### 1. JwtTokenProvider

Handles token generation and validation:
- `generateAccessToken(UserDetails)` - Creates access token
- `generateRefreshToken(UserDetails)` - Creates refresh token
- `extractUsername(String token)` - Extracts username from token
- `isTokenValid(String token, UserDetails)` - Validates token

### 2. JwtAuthenticationFilter

Extends `OncePerRequestFilter`:
- Extracts token from `Authorization: Bearer <token>` header
- Validates token and sets SecurityContext
- Passes through if no token (for public endpoints)

### 3. SecurityConfig

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/actuator/health").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
            .build();
    }
}
```

## Authentication Endpoints

### POST /api/auth/register
Request: `{ "email", "password", "firstName", "lastName" }`
Response: `{ "accessToken", "refreshToken", "user": {...} }`

### POST /api/auth/login
Request: `{ "email", "password" }`
Response: `{ "accessToken", "refreshToken", "user": {...} }`

### POST /api/auth/refresh
Request: `{ "refreshToken" }`
Response: `{ "accessToken", "refreshToken", "user": {...} }`

## DTOs

Use Java records for auth DTOs:

```java
public record LoginRequest(
    @NotBlank @Email String email,
    @NotBlank String password
) {}

public record RegisterRequest(
    @NotBlank @Email String email,
    @NotBlank @Size(min = 8) String password,
    @NotBlank String firstName,
    @NotBlank String lastName
) {}

public record AuthResponse(
    String accessToken,
    String refreshToken,
    String tokenType,
    long expiresIn,
    UserResponse user
) {}
```

## CORS Configuration

```java
@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration config = new CorsConfiguration();
    config.setAllowedOrigins(List.of("http://localhost:5173"));
    config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH"));
    config.setAllowedHeaders(List.of("*"));
    config.setAllowCredentials(true);
    
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/api/**", config);
    return source;
}
```

## Security Best Practices

1. **JWT Secret**: Minimum 256 bits, use environment variable
2. **Token Duration**: Access token 15min-24h, Refresh token 7-30 days
3. **Password Encoding**: Always use BCryptPasswordEncoder
4. **HTTPS**: Required in production
5. **Rate Limiting**: Implement on auth endpoints

