package com.groupprojet.repository;

import com.groupprojet.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByUserIdUser(Long userId);
    List<Notification> findByUserIdUserAndIsReadFalse(Long userId);
}
