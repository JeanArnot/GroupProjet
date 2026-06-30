package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "tasks")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Task {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idTask;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_project", referencedColumnName = "idProject")
    private Project project;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_to", referencedColumnName = "idUser")
    private User assignedTo;

    @Column(nullable = false, length = 200)
    private String taskTitle;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(length = 50)
    private String taskCode;

    @Column(length = 20)
    private String priority = "MEDIUM";

    @Column(length = 20)
    private String status = "TODO";

    @Column(precision = 5, scale = 2)
    private BigDecimal progress = BigDecimal.ZERO;

    private Integer estimatedTime;

    private Integer spentTime = 0;

    private LocalDateTime startDate;

    private LocalDateTime deadline;

    private LocalDateTime completedAt;

    private Boolean isBlocked = false;

    @Column(length = 20)
    private String difficultyLevel;

    private Boolean reminderSent = false;

    private Integer attachmentCount = 0;

    private Integer commentCount = 0;

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
}
