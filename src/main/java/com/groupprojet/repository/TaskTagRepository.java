package com.groupprojet.repository;

import com.groupprojet.entity.TaskTag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskTagRepository extends JpaRepository<TaskTag, Long> {
    List<TaskTag> findByTaskIdTask(Long taskId);
}
