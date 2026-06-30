package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "comment_mentions", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "id_comment", "id_user" })
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CommentMention {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_mention")
    private Long idMention;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_comment", nullable = false)
    private Comment comment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user", nullable = false)
    private User user;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
