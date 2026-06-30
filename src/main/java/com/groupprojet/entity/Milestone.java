package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "milestones")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Milestone {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idMilestone;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_project", referencedColumnName = "idProject")
    private Project project;

    @Column(length = 200)
    private String milestoneName;

    @Column(columnDefinition = "TEXT")
    private String description;

    private LocalDate dueDate;

    @Column(length = 20)
    private String status = "PENDING";

    @Column(precision = 5, scale = 2)
    private BigDecimal completionPercentage = BigDecimal.ZERO;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", referencedColumnName = "idUser")
    private User createdBy;

    @Column(updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
