package com.groupprojet.repository;

import com.groupprojet.entity.TaskChecklist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskChecklistRepository extends JpaRepository<TaskChecklist, Long> {
    List<TaskChecklist> findByTaskIdTaskOrderByPositionAsc(Long taskId);
}
