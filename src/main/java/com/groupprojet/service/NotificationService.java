package com.groupprojet.service;

import com.groupprojet.entity.Notification;
import com.groupprojet.entity.User;
import com.groupprojet.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final SimpMessagingTemplate messagingTemplate;

    public Notification createAndSendNotification(User user, String title, String message, String type) {
        // 1. Save to DB
        Notification notif = new Notification();
        notif.setUser(user);
        notif.setTitle(title);
        notif.setMessage(message);
        notif.setNotificationType(type);
        Notification savedNotif = notificationRepository.save(notif);

        // 2. Send via WebSocket (Real-Time)
        // Sends to /user/{username}/topic/notifications
        messagingTemplate.convertAndSendToUser(
                user.getUsername(),
                "/topic/notifications",
                savedNotif);

        return savedNotif;
    }

    public List<Notification> getAllNotificationsByUser(Long userId) {
        return notificationRepository.findByUserIdUser(userId);
    }

    public List<Notification> getUnreadNotifications(Long userId) {
        return notificationRepository.findByUserIdUserAndIsReadFalse(userId);
    }

    public void markAsRead(Long notificationId) {
        notificationRepository.findById(notificationId).ifPresent(n -> {
            n.setIsRead(true);
            notificationRepository.save(n);
        });
    }
}
