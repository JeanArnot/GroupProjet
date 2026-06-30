package com.groupprojet.repository;

import com.groupprojet.entity.AdminAction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AdminActionRepository extends JpaRepository<AdminAction, Long> {
}
