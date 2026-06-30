package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "Organizations")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Organization {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idOrganization;

    @Column(nullable = false, length = 150)
    private String OrganizationName;

    @Column(columnDefinition = "TEXT")
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", referencedColumnName = "idUser")
    private User createdBy;

    @Column(columnDefinition = "TEXT")
    private String OrganizationImage;

    @Column(unique = true, length = 50)
    private String accessCode;

    @Column(length = 20)
    private String visibility = "PRIVATE";

    @Column(length = 20)
    private String status = "ACTIVE";

    @Column(updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
