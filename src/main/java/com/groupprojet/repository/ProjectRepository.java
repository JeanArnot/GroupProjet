package com.groupprojet.repository;

import com.groupprojet.entity.Project;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProjectRepository extends JpaRepository<Project, Long> {
    List<Project> findByOrganizationIdOrganization(Long OrganizationId);
    List<Project> findByCreatedByIdUser(Long userId);
}
