package com.example.app.dto;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        long expiresIn
) {}

