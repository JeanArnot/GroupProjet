package com.groupprojet.service;

import com.groupprojet.dto.FileDTO;
import com.groupprojet.entity.FileEntity;
import com.groupprojet.entity.Task;
import com.groupprojet.entity.User;
import com.groupprojet.repository.FileRepository;
import com.groupprojet.repository.TaskRepository;
import com.groupprojet.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FileService {

    private final FileRepository fileRepository;
    private final TaskRepository taskRepository;
    private final UserRepository userRepository;

    private final String UPLOAD_DIR = "uploads/";

    public FileDTO uploadFileToTask(Long taskId, Long userId, MultipartFile file) throws IOException {
        Task task = taskRepository.findById(taskId).orElseThrow();
        User user = userRepository.findById(userId).orElseThrow();

        // Save physical file
        Path uploadPath = Paths.get(UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        String fileName = UUID.randomUUID() + "_" + file.getOriginalFilename();
        Path filePath = uploadPath.resolve(fileName);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        // Save DB Entity
        FileEntity fileEntity = new FileEntity();
        fileEntity.setTask(task);
        fileEntity.setUploadedBy(user);
        fileEntity.setFileName(file.getOriginalFilename());
        fileEntity.setFileUrl("/uploads/" + fileName); // Path to serve
        fileEntity.setFileSize(file.getSize());
        fileEntity.setFileType(file.getContentType());

        FileEntity savedFile = fileRepository.save(fileEntity);

        // Update task attachment count
        task.setAttachmentCount(task.getAttachmentCount() + 1);
        taskRepository.save(task);

        return mapToDTO(savedFile);
    }

    public List<FileDTO> getFilesByTask(Long taskId) {
        return fileRepository.findByTaskIdTask(taskId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<FileDTO> getFilesByProject(Long projectId) {
        return fileRepository.findByProjectIdProject(projectId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<FileDTO> getFilesByUser(Long userId) {
        return fileRepository.findByUploadedByIdUser(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    private FileDTO mapToDTO(FileEntity f) {
        FileDTO dto = new FileDTO();
        dto.setIdFile(f.getIdFile());
        dto.setName(f.getFileName());
        dto.setOriginalFileName(f.getFileName());
        dto.setFileUrl(f.getFileUrl());
        dto.setSize(f.getFileSize());
        dto.setType(f.getFileType());
        dto.setUploadDate(f.getUploadedAt());
        if (f.getUploadedBy() != null) {
            dto.setUploadedById(f.getUploadedBy().getIdUser());
            dto.setUploadedBy(f.getUploadedBy().getFirstName() != null ? f.getUploadedBy().getFirstName()
                    : f.getUploadedBy().getUsername());
        }
        return dto;
    }
}
