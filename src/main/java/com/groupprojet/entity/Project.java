package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "projects")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Project {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idProject;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_Organization", referencedColumnName = "idOrganization")
    private Organization Organization;

    @Column(nullable = false, length = 200)
    private String projectName;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(unique = true, length = 50)
    private String projectCode;

    @Column(length = 30)
    private String status = "PLANNING";

    @Column(length = 20)
    private String priority = "MEDIUM";

    @Column(precision = 5, scale = 2)
    private BigDecimal progress = BigDecimal.ZERO;

    @Column(length = 20)
    private String healthStatus = "GOOD";

    private LocalDate startDate;

    private LocalDate endDate;

    private Integer estimatedHours;

    private Integer completedTasks = 0;

    private Integer totalTasks = 0;

    @Column(length = 20)
    private String projectColor;

    private Boolean archived = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", referencedColumnName = "idUser")
    private User createdBy;

    @Column(updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt = LocalDateTime.now();

    @PreUpdate
    public void setUpdatedAt() {
        this.updatedAt = LocalDateTime.now();
    }

    // ACADEMIC FIELDS
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_course")
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_academic_year")
    private AcademicYear academicYear;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_supervisor")
    private Supervisor supervisor;

    @Column(name = "academic_deadline")
    private LocalDate academicDeadline;

    @Column(name = "max_members")
    private Integer maxMembers;

    @Column(name = "submission_status", length = 20)
    private String submissionStatus = "NOT_SUBMITTED";

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;

    @Column(precision = 5, scale = 2)
    private BigDecimal grade;

    @Column(name = "grade_comment", columnDefinition = "TEXT")
    private String gradeComment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "graded_by")
    private User gradedBy;

    @Column(name = "graded_at")
    private LocalDateTime gradedAt;
}
