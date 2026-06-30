package com.groupprojet.repository;

import com.groupprojet.entity.Submission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SubmissionRepository extends JpaRepository<Submission, Long> {
    List<Submission> findByProjectIdProject(Long projectId);

    List<Submission> findBySubmittedByIdUser(Long userId);
}
