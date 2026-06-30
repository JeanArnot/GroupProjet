package com.groupprojet.service;

import com.groupprojet.dto.AuthRequestDTO;
import com.groupprojet.dto.AuthResponseDTO;
import com.groupprojet.dto.SocialAuthRequestDTO;
import com.groupprojet.dto.UserDTO;
import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import com.groupprojet.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Locale;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    public AuthResponseDTO register(User user) {
        normalizeUserForRegistration(user);
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Username already exists");
        }
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setLastLogin(LocalDateTime.now());
        User savedUser = userRepository.save(user);

        org.springframework.security.core.userdetails.User userDetails = new org.springframework.security.core.userdetails.User(
                savedUser.getUsername(),
                savedUser.getPassword(),
                new ArrayList<>());

        String token = jwtService.generateToken(userDetails);

        return new AuthResponseDTO(token, mapToDTO(savedUser));
    }

    public AuthResponseDTO authenticate(AuthRequestDTO request) {
        if (request.getUsername() == null || request.getUsername().isBlank()
                || request.getPassword() == null || request.getPassword().isBlank()) {
            throw new RuntimeException("Username/email and password are required");
        }

        // Authenticate using the provided username (which might be an email)
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getUsername(),
                        request.getPassword()));

        // Fetch user from DB to generate token (lookup by username or email)
        User user = userRepository.findByUsernameOrEmail(request.getUsername(), request.getUsername())
                .orElseThrow();

        org.springframework.security.core.userdetails.User userDetails = new org.springframework.security.core.userdetails.User(
                user.getUsername(),
                user.getPassword(),
                new ArrayList<>());

        String token = jwtService.generateToken(userDetails);
        user.setLastLogin(LocalDateTime.now());
        userRepository.save(user);

        return new AuthResponseDTO(token, mapToDTO(user));
    }

    public AuthResponseDTO socialLogin(SocialAuthRequestDTO request) {
        if (request.getProvider() == null || request.getProvider().isBlank()) {
            throw new RuntimeException("Provider is required");
        }
        if (request.getEmail() == null || request.getEmail().isBlank()) {
            throw new RuntimeException("Email is required");
        }

        String email = request.getEmail().trim().toLowerCase(Locale.ROOT);
        User user = userRepository.findByEmail(email).orElseGet(() -> {
            User created = new User();
            created.setEmail(email);
            created.setUsername(generateUniqueUsername(email, request.getProvider()));
            created.setFirstName(defaultIfBlank(request.getFirstName(), request.getProvider()));
            created.setLastName(defaultIfBlank(request.getLastName(), "User"));
            created.setRole("MEMBER");
            created.setStatus("ACTIVE");
            created.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));
            created.setProfileImage(request.getProfileImage());
            return created;
        });

        if (request.getFirstName() != null && !request.getFirstName().isBlank()) {
            user.setFirstName(request.getFirstName().trim());
        }
        if (request.getLastName() != null && !request.getLastName().isBlank()) {
            user.setLastName(request.getLastName().trim());
        }
        if (request.getProfileImage() != null && !request.getProfileImage().isBlank()) {
            user.setProfileImage(request.getProfileImage().trim());
        }
        user.setLastLogin(LocalDateTime.now());

        User savedUser = userRepository.save(user);
        org.springframework.security.core.userdetails.User userDetails = new org.springframework.security.core.userdetails.User(
                savedUser.getUsername(),
                savedUser.getPassword(),
                new ArrayList<>());

        String token = jwtService.generateToken(userDetails);
        return new AuthResponseDTO(token, mapToDTO(savedUser));
    }

    private void normalizeUserForRegistration(User user) {
        if (user.getEmail() == null || user.getEmail().isBlank()) {
            throw new RuntimeException("Email is required");
        }
        if (user.getPassword() == null || user.getPassword().isBlank()) {
            throw new RuntimeException("Password is required");
        }

        user.setEmail(user.getEmail().trim().toLowerCase(Locale.ROOT));
        if (user.getUsername() == null || user.getUsername().isBlank()) {
            user.setUsername(generateUniqueUsername(user.getEmail(), "user"));
        } else {
            user.setUsername(user.getUsername().trim().toLowerCase(Locale.ROOT));
        }
        user.setFirstName(defaultIfBlank(user.getFirstName(), "User"));
        user.setLastName(defaultIfBlank(user.getLastName(), "Member"));
        if (user.getRole() == null || user.getRole().isBlank()) {
            user.setRole("MEMBER");
        }
        if (user.getStatus() == null || user.getStatus().isBlank()) {
            user.setStatus("ACTIVE");
        }
    }

    private String generateUniqueUsername(String email, String fallbackPrefix) {
        String base = email != null && email.contains("@")
                ? email.substring(0, email.indexOf('@'))
                : fallbackPrefix;
        base = base.toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9._-]", "");
        if (base.isBlank()) {
            base = fallbackPrefix.toLowerCase(Locale.ROOT);
        }

        String candidate = base;
        int suffix = 1;
        while (userRepository.existsByUsername(candidate)) {
            candidate = base + suffix;
            suffix++;
        }
        return candidate;
    }

    private String defaultIfBlank(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value.trim();
    }

    private UserDTO mapToDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setIdUser(user.getIdUser());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setRole(user.getRole());
        dto.setProfileImage(user.getProfileImage());
        return dto;
    }
}
