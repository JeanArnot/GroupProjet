package com.groupprojet.controller;

import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import com.groupprojet.service.GradeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/grades")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class GradeController {

    private final GradeService gradeService;
    private final UserRepository userRepository;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getMyGrades() {
        return ResponseEntity.ok(gradeService.getGradesSummaryForUser(getCurrentUserId()));
    }

    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal())) {
            String username = authentication.getName();
            return userRepository.findByUsername(username)
                    .map(User::getIdUser)
                    .orElse(1L); // Fallback
        }
        return 1L; // Fallback for development
    }
}
