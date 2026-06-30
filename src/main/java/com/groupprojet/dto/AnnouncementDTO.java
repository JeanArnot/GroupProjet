package com.groupprojet.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AnnouncementDTO {
    private Long idAnnouncement;
    private Long projectId;
    private String projectName;
    private String title;
    private String content;
    private String type;
    private Boolean isPinned;
    private LocalDateTime publishDate;
    private LocalDateTime expiryDate;
    private Long createdById;
    private String createdBy;
}
