package com.vsco.clone.controller;

import com.vsco.clone.dto.AuthResponse;
import com.vsco.clone.dto.LoginRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        // Mocking authentication for now
        if ("user@vsco.com".equals(request.getEmail()) && "password".equals(request.getPassword())) {
            return ResponseEntity.ok(new AuthResponse("mock-jwt-token", request.getEmail()));
        }
        return ResponseEntity.status(401).build();
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody LoginRequest request) {
        // Mocking registration
        return ResponseEntity.ok("User registered successfully");
    }
}
