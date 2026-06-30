package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "invitations")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Invitation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_invitation")
    private Long idInvitation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_Organization")
    private Organization Organization;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_project")
    private Project project;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "invited_by", nullable = false)
    private User invitedBy;

    @Column(name = "invited_email", nullable = false, length = 150)
    private String invitedEmail;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user")
    private User user;

    @Column(name = "role_to_assign", nullable = false, length = 30)
    private String roleToAssign = "MEMBER";

    @Column(nullable = false, unique = true)
    private String token;

    @Column(columnDefinition = "TEXT")
    private String message;

    @Column(nullable = false, length = 20)
    private String status = "PENDING";

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "accepted_at")
    private LocalDateTime acceptedAt;

    @Column(name = "declined_at")
    private LocalDateTime declinedAt;

    @Column(name = "decline_reason", columnDefinition = "TEXT")
    private String declineReason;

    @Column(name = "sent_count", nullable = false)
    private Integer sentCount = 1;

    @Column(name = "last_sent_at", nullable = false)
    private LocalDateTime lastSentAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
