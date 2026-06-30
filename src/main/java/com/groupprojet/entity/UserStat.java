package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_stats")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserStat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_stat")
    private Long idStat;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user", nullable = false, unique = true)
    private User user;

    @Column(name = "total_projects", nullable = false)
    private Integer totalProjects = 0;

    @Column(name = "total_tasks_done", nullable = false)
    private Integer totalTasksDone = 0;

    @Column(name = "total_Organizations", nullable = false)
    private Integer totalOrganizations = 0;

    @Column(name = "total_submissions", nullable = false)
    private Integer totalSubmissions = 0;

    @Column(name = "avg_grade", precision = 5, scale = 2)
    private java.math.BigDecimal avgGrade;

    @Column(name = "best_grade", precision = 5, scale = 2)
    private java.math.BigDecimal bestGrade;

    @Column(name = "total_comments", nullable = false)
    private Integer totalComments = 0;

    @Column(name = "total_files", nullable = false)
    private Integer totalFiles = 0;

    @Column(name = "streak_days", nullable = false)
    private Integer streakDays = 0;

    @Column(name = "last_active_date")
    private LocalDate lastActiveDate;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
