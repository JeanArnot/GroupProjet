package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "project_MEMBREs")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProjectMember {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idProjectMember;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_project", referencedColumnName = "idProject")
    private Project project;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user", referencedColumnName = "idUser")
    private User user;

    @Column(length = 30)
    private String roleInProject = "MEMBRE";

    @Column(updatable = false)
    private LocalDateTime assignedAt = LocalDateTime.now();
}
