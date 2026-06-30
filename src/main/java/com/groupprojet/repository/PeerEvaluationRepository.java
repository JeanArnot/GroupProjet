package com.groupprojet.repository;

import com.groupprojet.entity.PeerEvaluation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PeerEvaluationRepository extends JpaRepository<PeerEvaluation, Long> {
    List<PeerEvaluation> findByProjectIdProject(Long projectId);
}
