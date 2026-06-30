package com.groupprojet.repository;

import com.groupprojet.entity.TaskDependency;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskDependencyRepository extends JpaRepository<TaskDependency, Long> {
    List<TaskDependency> findByTaskIdTask(Long taskId);
    List<TaskDependency> findByDependsOnTaskIdTask(Long dependsOnTaskId);
}
