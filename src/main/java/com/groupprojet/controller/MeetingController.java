package com.groupprojet.controller;

import com.groupprojet.dto.MeetingDTO;
import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import com.groupprojet.service.MeetingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/meetings")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class MeetingController {

    private final MeetingService meetingService;
    private final UserRepository userRepository;

    static class MeetingRequest {
        public Long projectId;
        public String title;
        public String description;
        public LocalDateTime date;
        public int durationMinutes;
    }

    @PostMapping("/schedule")
    public ResponseEntity<MeetingDTO> scheduleMeeting(@RequestBody MeetingRequest req) {
        return ResponseEntity.ok(meetingService.scheduleMeeting(
                req.projectId, getCurrentUserId(), req.title, req.description, req.date, req.durationMinutes));
    }

    @GetMapping("/project/{projectId}")
    public ResponseEntity<List<MeetingDTO>> getProjectMeetings(@PathVariable Long projectId) {
        return ResponseEntity.ok(meetingService.getMeetingsByProject(projectId));
    }

    @GetMapping
    public ResponseEntity<List<MeetingDTO>> getMyMeetings() {
        return ResponseEntity.ok(meetingService.getMeetingsByUser(getCurrentUserId()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<MeetingDTO> getMeeting(@PathVariable Long id) {
        return ResponseEntity.ok(meetingService.getMeetingById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<MeetingDTO> updateMeeting(@PathVariable Long id, @RequestBody MeetingDTO dto) {
        return ResponseEntity.ok(meetingService.updateMeeting(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMeeting(@PathVariable Long id) {
        meetingService.deleteMeeting(id);
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
