package com.groupprojet.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class TaskDTO {
    private Long idTask;
    private Long projectId;
    private String projectName; // Added for frontend display
    private Long assignedToId;
    private String assigneeName; // Added for frontend display
    private String taskTitle;
    private String description;
    private String taskCode;
    private String priority;
    private String status;
    private BigDecimal progress;
    private Integer estimatedTime;
    private LocalDateTime deadline;
}
