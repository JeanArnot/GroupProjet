package com.groupprojet.controller;

import com.groupprojet.dto.UserDTO;
import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class UserController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @GetMapping
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        // Normally you might want to return only users from the same Organization/project
        // but for now we'll return all users (excluding sensitive data)
        List<UserDTO> users = userRepository.findAll().stream().map(this::mapToDTO).collect(Collectors.toList());
        return ResponseEntity.ok(users);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUser(@PathVariable Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return ResponseEntity.ok(mapToDTO(user));
    }

    @PostMapping
    public ResponseEntity<UserDTO> createUser(@RequestBody User user) {
        normalizeUser(user);
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email already exists");
        }
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Username already exists");
        }
        if (user.getPassword() == null || user.getPassword().isBlank()) {
            user.setPassword("password123");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return ResponseEntity.ok(mapToDTO(userRepository.save(user)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserDTO> updateUser(@PathVariable Long id, @RequestBody User request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (request.getFirstName() != null) user.setFirstName(request.getFirstName().trim());
        if (request.getLastName() != null) user.setLastName(request.getLastName().trim());
        if (request.getUsername() != null && !request.getUsername().isBlank()) user.setUsername(request.getUsername().trim().toLowerCase(Locale.ROOT));
        if (request.getEmail() != null && !request.getEmail().isBlank()) user.setEmail(request.getEmail().trim().toLowerCase(Locale.ROOT));
        if (request.getRole() != null && !request.getRole().isBlank()) user.setRole(request.getRole().trim().toUpperCase(Locale.ROOT));
        if (request.getStatus() != null && !request.getStatus().isBlank()) user.setStatus(request.getStatus().trim().toUpperCase(Locale.ROOT));
        if (request.getPhone() != null) user.setPhone(request.getPhone().trim());
        if (request.getUniversity() != null) user.setUniversity(request.getUniversity().trim());
        if (request.getSpeciality() != null) user.setSpeciality(request.getSpeciality().trim());
        if (request.getProfileImage() != null) user.setProfileImage(request.getProfileImage().trim());
        if (request.getPassword() != null && !request.getPassword().isBlank()) {
            user.setPassword(passwordEncoder.encode(request.getPassword()));
        }

        return ResponseEntity.ok(mapToDTO(userRepository.save(user)));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<UserDTO> updateStatus(@PathVariable Long id, @RequestParam String status) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setStatus(status.trim().toUpperCase(Locale.ROOT));
        return ResponseEntity.ok(mapToDTO(userRepository.save(user)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("User not found");
        }
        userRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    private void normalizeUser(User user) {
        if (user.getEmail() != null) user.setEmail(user.getEmail().trim().toLowerCase(Locale.ROOT));
        if (user.getUsername() == null || user.getUsername().isBlank()) {
            String base = user.getEmail() != null && user.getEmail().contains("@")
                    ? user.getEmail().substring(0, user.getEmail().indexOf('@'))
                    : "user";
            user.setUsername(base.replaceAll("[^a-zA-Z0-9._-]", "").toLowerCase(Locale.ROOT));
        } else {
            user.setUsername(user.getUsername().trim().toLowerCase(Locale.ROOT));
        }
        if (user.getFirstName() == null || user.getFirstName().isBlank()) user.setFirstName("User");
        if (user.getLastName() == null || user.getLastName().isBlank()) user.setLastName("Member");
        if (user.getRole() == null || user.getRole().isBlank()) user.setRole("MEMBER");
        if (user.getStatus() == null || user.getStatus().isBlank()) user.setStatus("ACTIVE");
        user.setRole(user.getRole().trim().toUpperCase(Locale.ROOT));
        user.setStatus(user.getStatus().trim().toUpperCase(Locale.ROOT));
    }

    private UserDTO mapToDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setIdUser(user.getIdUser());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setRole(user.getRole());
        dto.setStatus(user.getStatus());
        dto.setPhone(user.getPhone());
        dto.setUniversity(user.getUniversity());
        dto.setSpeciality(user.getSpeciality());
        dto.setProfileImage(user.getProfileImage());
        return dto;
    }
}
