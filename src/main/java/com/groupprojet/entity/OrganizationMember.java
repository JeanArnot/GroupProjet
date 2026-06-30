package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "Organization_MEMBREs")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrganizationMember {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idOrganizationMember;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_Organization", referencedColumnName = "idOrganization")
    private Organization Organization;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user", referencedColumnName = "idUser")
    private User user;

    @Column(length = 20)
    private String MEMBRERole = "MEMBRE";

    @Column(updatable = false)
    private LocalDateTime joinedAt = LocalDateTime.now();
}
