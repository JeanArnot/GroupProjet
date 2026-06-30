package com.groupprojet.repository;

import com.groupprojet.entity.ProjectTemplate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProjectTemplateRepository extends JpaRepository<ProjectTemplate, Long> {
    List<ProjectTemplate> findByOrganizationIdOrganization(Long OrganizationId);
}
