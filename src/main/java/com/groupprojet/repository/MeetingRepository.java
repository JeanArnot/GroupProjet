package com.groupprojet.repository;

import com.groupprojet.entity.Meeting;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MeetingRepository extends JpaRepository<Meeting, Long> {
    List<Meeting> findByProjectIdProject(Long projectId);

    List<Meeting> findByCreatedByIdUser(Long userId);
}
