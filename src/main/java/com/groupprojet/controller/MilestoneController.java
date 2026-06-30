package com.groupprojet.controller;

import com.groupprojet.dto.MilestoneDTO;
import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import com.groupprojet.service.MilestoneService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/milestones")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class MilestoneController {
    private final MilestoneService milestoneService;
    private final UserRepository userRepository;

    @PostMapping
    public ResponseEntity<MilestoneDTO> createMilestone(@RequestBody MilestoneDTO dto) {
        return ResponseEntity.ok(milestoneService.createMilestone(dto, getCurrentUserId()));
    }

    @GetMapping("/project/{projectId}")
    public ResponseEntity<List<MilestoneDTO>> getMilestonesByProject(@PathVariable Long projectId) {
        return ResponseEntity.ok(milestoneService.getMilestonesByProject(projectId));
    }

    @GetMapping
    public ResponseEntity<List<MilestoneDTO>> getMyMilestones() {
        return ResponseEntity.ok(milestoneService.getMilestonesByUser(getCurrentUserId()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<MilestoneDTO> getMilestone(@PathVariable Long id) {
        return ResponseEntity.ok(milestoneService.getMilestoneById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<MilestoneDTO> updateMilestone(@PathVariable Long id, @RequestBody MilestoneDTO dto) {
        return ResponseEntity.ok(milestoneService.updateMilestone(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMilestone(@PathVariable Long id) {
        milestoneService.deleteMilestone(id);
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
