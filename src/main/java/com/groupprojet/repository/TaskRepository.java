package com.groupprojet.repository;

import com.groupprojet.entity.Task;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findByProjectIdProject(Long projectId);
    List<Task> findByAssignedToIdUser(Long userId);
    
    long countByProjectIdProject(Long projectId);
    long countByProjectIdProjectAndStatus(Long projectId, String status);
}
