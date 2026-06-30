package com.groupprojet.repository;

import com.groupprojet.entity.OrganizationMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrganizationMemberRepository extends JpaRepository<OrganizationMember, Long> {
    List<OrganizationMember> findByOrganizationIdOrganization(Long OrganizationId);
    List<OrganizationMember> findByUserIdUser(Long userId);
    Optional<OrganizationMember> findByOrganizationIdOrganizationAndUserIdUser(Long OrganizationId, Long userId);
}
