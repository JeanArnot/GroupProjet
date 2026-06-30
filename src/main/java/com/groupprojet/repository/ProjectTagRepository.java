package com.groupprojet.repository;

import com.groupprojet.entity.ProjectTag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProjectTagRepository extends JpaRepository<ProjectTag, Long> {
    List<ProjectTag> findByProjectIdProject(Long projectId);
}
