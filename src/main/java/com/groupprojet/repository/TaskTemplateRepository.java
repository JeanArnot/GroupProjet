package com.groupprojet.repository;

import com.groupprojet.entity.TaskTemplate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskTemplateRepository extends JpaRepository<TaskTemplate, Long> {
    List<TaskTemplate> findByProjectIdProject(Long projectId);
}
