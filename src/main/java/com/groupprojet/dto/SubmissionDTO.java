package com.groupprojet.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class SubmissionDTO {
    private Long idSubmission;
    private Long projectId;
    private String projectName;
    private Long taskId;
    private Long milestoneId;
    private Long submittedById;
    private String submittedBy;
    private String submissionTitle;
    private String submissionNote;
    private java.util.List<String> fileUrls;
    private String status;
    private BigDecimal grade;
    private String feedback;
    private LocalDateTime evaluatedAt;
    private LocalDateTime dueDate;
    private LocalDateTime submittedAt;
    private Boolean isLate;
    private Integer lateDurationHours;
}
