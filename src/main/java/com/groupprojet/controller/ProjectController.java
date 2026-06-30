package com.groupprojet.controller;

import com.groupprojet.dto.ProjectDTO;
import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import com.groupprojet.service.ProjectService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/projects")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProjectController {

    private final ProjectService projectService;
    private final UserRepository userRepository;

    @PostMapping
    public ResponseEntity<ProjectDTO> createProject(@RequestBody ProjectDTO projectDTO) {
        return ResponseEntity.ok(projectService.createProject(projectDTO, getCurrentUserId()));
    }

    @GetMapping
    public ResponseEntity<List<ProjectDTO>> getAllProjectsForUser() {
        return ResponseEntity.ok(projectService.getProjectsByUser(getCurrentUserId()));
    }

    @GetMapping("/Organization/{OrganizationId}")
    public ResponseEntity<List<ProjectDTO>> getProjectsByOrganization(@PathVariable Long OrganizationId) {
        return ResponseEntity.ok(projectService.getProjectsByOrganization(OrganizationId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProjectDTO> getProjectById(@PathVariable Long id) {
        return ResponseEntity.ok(projectService.getProjectById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProjectDTO> updateProject(@PathVariable Long id, @RequestBody ProjectDTO projectDTO) {
        return ResponseEntity.ok(projectService.updateProject(id, projectDTO));
    }

    @PutMapping("/{id}/archive")
    public ResponseEntity<ProjectDTO> archiveProject(@PathVariable Long id) {
        return ResponseEntity.ok(projectService.archiveProject(id));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProject(@PathVariable Long id) {
        projectService.deleteProject(id);
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
