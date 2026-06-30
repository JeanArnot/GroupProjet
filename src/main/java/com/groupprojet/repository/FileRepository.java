package com.groupprojet.repository;

import com.groupprojet.entity.FileEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FileRepository extends JpaRepository<FileEntity, Long> {
    List<FileEntity> findByTaskIdTask(Long taskId);

    List<FileEntity> findByProjectIdProject(Long projectId);

    List<FileEntity> findByUploadedByIdUser(Long userId);
}
