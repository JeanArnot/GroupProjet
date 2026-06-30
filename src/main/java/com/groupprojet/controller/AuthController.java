package com.groupprojet.controller;

import com.groupprojet.dto.AuthRequestDTO;
import com.groupprojet.dto.AuthResponseDTO;
import com.groupprojet.dto.SocialAuthRequestDTO;
import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import com.groupprojet.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;
    private final PasswordEncoder passwordEncoder;
    private final UserRepository userRepository;

    @PostMapping("/register")
    public ResponseEntity<AuthResponseDTO> register(@RequestBody User request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponseDTO> authenticate(@RequestBody AuthRequestDTO request) {
        return ResponseEntity.ok(authService.authenticate(request));
    }

    @PostMapping("/social-login")
    public ResponseEntity<AuthResponseDTO> socialLogin(@RequestBody SocialAuthRequestDTO request) {
        return ResponseEntity.ok(authService.socialLogin(request));
    }

    @GetMapping("/hash")
    public String hash(@RequestParam String pwd) {
        return passwordEncoder.encode(pwd);
    }

    // Emergency endpoint to fix all passwords to "password123" just in case the
    // migration hash was incorrect
    @GetMapping("/fix-passwords")
    public String fixPasswords() {
        List<User> users = userRepository.findAll();
        String hash = passwordEncoder.encode("password123");
        for (User u : users) {
            u.setPassword(hash);
            userRepository.save(u);
        }
        return "All passwords have been reset to 'password123' with the correct hash!";
    }
}
