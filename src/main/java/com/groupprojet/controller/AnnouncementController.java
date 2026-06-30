package com.groupprojet.controller;

import com.groupprojet.dto.AnnouncementDTO;
import com.groupprojet.entity.Announcement;
import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import com.groupprojet.service.AnnouncementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/announcements")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AnnouncementController {

    private final AnnouncementService announcementService;
    private final UserRepository userRepository;

    @GetMapping("/all")
    public ResponseEntity<List<AnnouncementDTO>> getAllAnnouncements() {
        return ResponseEntity.ok(announcementService.getAllAnnouncements());
    }

    @GetMapping
    public ResponseEntity<List<AnnouncementDTO>> getMyAnnouncements() {
        return ResponseEntity.ok(announcementService.getAnnouncementsByUser(getCurrentUserId()));
    }

    @GetMapping("/project/{projectId}")
    public ResponseEntity<List<AnnouncementDTO>> getAnnouncementsByProject(@PathVariable Long projectId) {
        return ResponseEntity.ok(announcementService.getAnnouncementsByProject(projectId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<AnnouncementDTO> getAnnouncementById(@PathVariable Long id) {
        return announcementService.getAnnouncementById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<AnnouncementDTO> createAnnouncement(@RequestBody Announcement announcement) {
        User user = userRepository.findById(getCurrentUserId()).orElseThrow();
        announcement.setCreatedBy(user);
        return ResponseEntity.ok(announcementService.createAnnouncement(announcement));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAnnouncement(@PathVariable Long id) {
        announcementService.deleteAnnouncement(id);
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
