package com.example.app.service;

import com.example.app.dto.*;

public interface AuthService {

    AuthResponse register(RegisterRequest request);

    AuthResponse login(LoginRequest request);

    AuthResponse refreshToken(RefreshTokenRequest request);

    void logout(String userEmail);

    UserResponse getCurrentUser(String email);
}

