package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_productivity")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserProductivity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idProductivity;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user", referencedColumnName = "idUser")
    private User user;

    private Integer completedTasks = 0;

    private Integer lateTasks = 0;

    private Integer totalHoursWorked = 0;

    @Column(precision = 5, scale = 2)
    private BigDecimal productivityScore = BigDecimal.ZERO;

    private LocalDateTime updatedAt = LocalDateTime.now();

    @PreUpdate
    public void setUpdatedAt() {
        this.updatedAt = LocalDateTime.now();
    }
}
