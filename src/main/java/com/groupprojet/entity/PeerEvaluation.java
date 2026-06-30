package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "peer_evaluations", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "id_project", "evaluator_id", "evaluated_id" })
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PeerEvaluation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_evaluation")
    private Long idEvaluation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_project", nullable = false)
    private Project project;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "evaluator_id", nullable = false)
    private User evaluator;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "evaluated_id", nullable = false)
    private User evaluated;

    @Column(name = "score_participation")
    private Integer scoreParticipation;

    @Column(name = "score_communication")
    private Integer scoreCommunication;

    @Column(name = "score_quality")
    private Integer scoreQuality;

    @Column(name = "score_punctuality")
    private Integer scorePunctuality;

    @Column(name = "score_teamwork")
    private Integer scoreTeamwork;

    @Column(name = "overall_score", precision = 4, scale = 2)
    private java.math.BigDecimal overallScore;

    @Column(columnDefinition = "TEXT")
    private String comment;

    @Column(name = "is_anonymous", nullable = false)
    private Boolean isAnonymous = true;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
