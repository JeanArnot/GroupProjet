package com.groupprojet.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CalendarEventDTO {
    private Long idEvent;
    private String title;
    private String description;
    private String eventType;
    private String color;
    private LocalDateTime startDatetime;
    private LocalDateTime endDatetime;
    private Boolean allDay;
    private String location;
}
