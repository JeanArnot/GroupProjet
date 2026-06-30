package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "task_history")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaskHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idHistory;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_task", referencedColumnName = "idTask")
    private Task task;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "changed_by", referencedColumnName = "idUser")
    private User changedBy;

    @Column(length = 20)
    private String oldStatus;

    @Column(length = 20)
    private String newStatus;

    @Column(columnDefinition = "TEXT")
    private String changeDescription;

    @Column(updatable = false)
    private LocalDateTime changedAt = LocalDateTime.now();
}
