package com.groupprojet.repository;

import com.groupprojet.entity.ProjectMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProjectMemberRepository extends JpaRepository<ProjectMember, Long> {
    List<ProjectMember> findByProjectIdProject(Long projectId);
    List<ProjectMember> findByUserIdUser(Long userId);
}
