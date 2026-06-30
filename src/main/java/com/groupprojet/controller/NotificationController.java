package com.groupprojet.controller;

import com.groupprojet.dto.NotificationDTO;
import com.groupprojet.entity.Notification;
import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import com.groupprojet.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class NotificationController {

    private final NotificationService notificationService;
    private final UserRepository userRepository;

    @GetMapping
    public ResponseEntity<List<NotificationDTO>> getMyNotifications() {
        List<NotificationDTO> notifs = notificationService.getAllNotificationsByUser(getCurrentUserId())
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(notifs);
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok().build();
    }

    private NotificationDTO mapToDTO(Notification n) {
        NotificationDTO dto = new NotificationDTO();
        dto.setIdNotification(n.getIdNotification());
        dto.setTitle(n.getTitle());
        dto.setMessage(n.getMessage());
        dto.setType(n.getNotificationType());
        dto.setIsRead(n.getIsRead());
        dto.setActionUrl(n.getActionUrl());
        dto.setCreatedAt(n.getCreatedAt());
        return dto;
    }

    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal())) {
            String username = authentication.getName();
            return userRepository.findByUsername(username)
                    .map(User::getIdUser)
                    .orElse(1L);
        }
        return 1L;
    }
}
