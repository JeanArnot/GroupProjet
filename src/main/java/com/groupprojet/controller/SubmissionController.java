package com.groupprojet.controller;

import com.groupprojet.dto.SubmissionDTO;
import com.groupprojet.entity.Submission;
import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import com.groupprojet.service.SubmissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/submissions")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SubmissionController {

    private final SubmissionService submissionService;
    private final UserRepository userRepository;

    @GetMapping("/all")
    public ResponseEntity<List<SubmissionDTO>> getAllSubmissions() {
        return ResponseEntity.ok(submissionService.getAllSubmissions());
    }

    @GetMapping
    public ResponseEntity<List<SubmissionDTO>> getMySubmissions() {
        return ResponseEntity.ok(submissionService.getSubmissionsByUser(getCurrentUserId()));
    }

    @GetMapping("/project/{projectId}")
    public ResponseEntity<List<SubmissionDTO>> getSubmissionsByProject(@PathVariable Long projectId) {
        return ResponseEntity.ok(submissionService.getSubmissionsByProject(projectId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<SubmissionDTO> getSubmissionById(@PathVariable Long id) {
        return submissionService.getSubmissionById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<SubmissionDTO> createSubmission(@RequestBody SubmissionDTO dto) {
        return ResponseEntity.ok(submissionService.createSubmission(dto, getCurrentUserId()));
    }

    @PutMapping("/{id}")
    public ResponseEntity<SubmissionDTO> updateSubmission(@PathVariable Long id, @RequestBody SubmissionDTO dto) {
        return ResponseEntity.ok(submissionService.updateSubmission(id, dto, getCurrentUserId()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSubmission(@PathVariable Long id) {
        submissionService.deleteSubmission(id);
        return ResponseEntity.noContent().build();
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
