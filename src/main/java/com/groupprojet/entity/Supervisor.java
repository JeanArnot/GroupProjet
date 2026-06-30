package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "supervisors")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Supervisor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_supervisor")
    private Long idSupervisor;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user", nullable = false, unique = true)
    private User user;

    @Column(length = 50)
    private String title;

    @Column(length = 150)
    private String department;

    @Column(length = 150)
    private String university;

    @org.hibernate.annotations.Type(io.hypersistence.utils.hibernate.type.array.ListArrayType.class)
    @Column(columnDefinition = "text[]")
    private java.util.List<String> expertise;

    @Column(length = 100)
    private String office;

    @Column(name = "office_hours", columnDefinition = "TEXT")
    private String officeHours;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
