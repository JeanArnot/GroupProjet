package com.groupprojet.repository;

import com.groupprojet.entity.UserProductivity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserProductivityRepository extends JpaRepository<UserProductivity, Long> {
    Optional<UserProductivity> findByUserIdUser(Long userId);
}
