package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "task_templates")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TaskTemplate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_template")
    private Long idTemplate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_project")
    private Project project;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_Organization")
    private Organization Organization;

    @Column(name = "template_name", nullable = false, length = 200)
    private String templateName;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "template_data", nullable = false, columnDefinition = "jsonb")
    private String templateData;

    @Column(name = "is_public", nullable = false)
    private Boolean isPublic = false;

    @Column(name = "use_count", nullable = false)
    private Integer useCount = 0;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", nullable = false)
    private User createdBy;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
