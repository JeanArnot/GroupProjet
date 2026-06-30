package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "task_tags")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TaskTag {

    @EmbeddedId
    private TaskTagId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("idTask")
    @JoinColumn(name = "id_task")
    private Task task;

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
class TaskTagId implements java.io.Serializable {
    private Long idTask;
    private Long idTag;
}
