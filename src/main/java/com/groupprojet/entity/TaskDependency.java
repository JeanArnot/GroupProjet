package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "task_dependencies")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaskDependency {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idDependency;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "task_id", referencedColumnName = "idTask")
    private Task task;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "depends_on_task_id", referencedColumnName = "idTask")
    private Task dependsOnTask;
}
