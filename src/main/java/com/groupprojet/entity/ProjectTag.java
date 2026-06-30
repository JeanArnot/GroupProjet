package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "project_tags")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProjectTag {

    @EmbeddedId
    private ProjectTagId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("idProject")
    @JoinColumn(name = "id_project")
    private Project project;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("idTag")
    @JoinColumn(name = "id_tag")
    private Tag tag;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tagged_by")
    private User taggedBy;

    @CreationTimestamp
    @Column(name = "tagged_at", nullable = false, updatable = false)
    private LocalDateTime taggedAt;
}

@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
class ProjectTagId implements java.io.Serializable {
    private Long idProject;
    private Long idTag;
}
