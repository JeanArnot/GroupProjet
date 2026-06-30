package com.groupprojet.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class ProjectDTO {
    private Long idProject;
    private Long OrganizationId;
    private String projectName;
    private String description;
    private String projectCode;
    private String status;
    private String priority;
    private BigDecimal progress;
    private String healthStatus;
    private LocalDate startDate;
    private LocalDate endDate;
}
