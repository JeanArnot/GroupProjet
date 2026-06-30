package com.groupprojet.repository;

import com.groupprojet.entity.Activity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ActivityRepository extends JpaRepository<Activity, Long> {
    List<Activity> findByProjectIdProject(Long projectId);
    List<Activity> findByUserIdUser(Long userId);
}
