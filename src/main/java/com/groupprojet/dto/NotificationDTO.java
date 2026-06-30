package com.groupprojet.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class NotificationDTO {
    private Long idNotification;
    private String title;
    private String message;
    private String type;
    private Boolean isRead;
    private String actionUrl;
    private LocalDateTime createdAt;
}
