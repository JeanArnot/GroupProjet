package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "activities")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Activity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idActivity;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user", referencedColumnName = "idUser")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_project", referencedColumnName = "idProject")
    private Project project;

    @Column(length = 100)
    private String activityType;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
