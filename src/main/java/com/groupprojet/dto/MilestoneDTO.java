package com.groupprojet.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class MilestoneDTO {
    private Long idMilestone;
    private Long projectId;
    private String milestoneName;
    private String description;
    private LocalDate dueDate;
    private String status;
    private BigDecimal completionPercentage;
}
