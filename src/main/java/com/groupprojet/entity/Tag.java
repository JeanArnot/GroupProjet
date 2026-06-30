package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "tags")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Tag {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_tag")
    private Long idTag;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_Organization")
    private Organization Organization;

    @Column(name = "tag_name", nullable = false, length = 50)
    private String tagName;

    @Column(name = "tag_color", nullable = false, length = 20)
    private String tagColor = "#6366F1";

    @Column(name = "tag_icon", length = 50)
    private String tagIcon;

    @Column(columnDefinition = "TEXT")
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
