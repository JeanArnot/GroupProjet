package com.groupprojet.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class MeetingDTO {
    private Long idMeeting;
    private Long projectId;
    private String title;
    private String description;
    private LocalDateTime meetingDate;
    private Integer durationMinutes;
    private String meetingLink;
    private String location;
    private String status;
    private String type;
}
