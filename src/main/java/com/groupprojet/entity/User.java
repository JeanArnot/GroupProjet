package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idUser;

    @Column(nullable = false, length = 100)
    private String firstName;

    @Column(nullable = false, length = 100)
    private String lastName;

    @Column(nullable = false, unique = true, length = 100)
    private String username;

    @Column(nullable = false, unique = true, length = 150)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(columnDefinition = "TEXT")
    private String profileImage;

    @Column(length = 20)
    private String role = "MEMBER";

    @Column(length = 30)
    private String phone;

    @Column(length = 150)
    private String university;

    @Column(length = 150)
    private String speciality;

    @Column(columnDefinition = "TEXT")
    private String bio;

    @Column(length = 20)
    private String status = "ACTIVE";

    private LocalDateTime lastLogin;

    @Column(updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt = LocalDateTime.now();

    @PreUpdate
    public void setUpdatedAt() {
        this.updatedAt = LocalDateTime.now();
    }

    // NEW PROFILE COLUMNS
    @Column(name = "cover_image", columnDefinition = "TEXT")
    private String coverImage;

    @Column(name = "social_github", length = 150)
    private String socialGithub;

    @Column(name = "social_linkedin", length = 150)
    private String socialLinkedin;

    @Column(name = "social_twitter", length = 150)
    private String socialTwitter;

    @Column(columnDefinition = "TEXT")
    private String website;

    @org.hibernate.annotations.Type(io.hypersistence.utils.hibernate.type.array.ListArrayType.class)
    @Column(columnDefinition = "text[]")
    private java.util.List<String> skills;

    @org.hibernate.annotations.Type(io.hypersistence.utils.hibernate.type.array.ListArrayType.class)
    @Column(columnDefinition = "text[]")
    private java.util.List<String> interests;

    @Column(name = "graduation_year")
    private Integer graduationYear;

    @Column(name = "is_supervisor", nullable = false)
    private Boolean isSupervisor = false;
}
