package com.groupprojet.repository;

import com.groupprojet.entity.Announcement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AnnouncementRepository extends JpaRepository<Announcement, Long> {
    List<Announcement> findByProjectIdProject(Long projectId);

    List<Announcement> findByCreatedByIdUser(Long userId);
}
