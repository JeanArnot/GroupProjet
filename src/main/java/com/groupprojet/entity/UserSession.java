package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_sessions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_session")
    private Long idSession;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user", nullable = false)
    private User user;

    @Column(name = "session_token", nullable = false, unique = true, length = 255)
    private String sessionToken;

    @Column(name = "refresh_token", unique = true, length = 255)
    private String refreshToken;

    @Column(name = "device_type", length = 30)
    private String deviceType;

    @Column(name = "device_name", length = 100)
    private String deviceName;

    @Column(length = 100)
    private String browser;

    @Column(length = 50)
    private String os;

    @Column(name = "ip_address", columnDefinition = "inet")
    private String ipAddress;

    @Column(length = 100)
    private String location;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "last_activity", nullable = false)
    private LocalDateTime lastActivity;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
