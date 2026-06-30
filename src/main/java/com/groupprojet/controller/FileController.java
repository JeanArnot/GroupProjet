package com.groupprojet.controller;

import com.groupprojet.dto.FileDTO;
import com.groupprojet.entity.FileEntity;
import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import com.groupprojet.service.FileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FileController {

    private final FileService fileService;
    private final UserRepository userRepository;

    @PostMapping("/task/{taskId}/upload")
    public ResponseEntity<FileDTO> uploadFile(
            @PathVariable Long taskId,
            @RequestParam("file") MultipartFile file) {
        try {
            FileDTO uploadedFile = fileService.uploadFileToTask(taskId, getCurrentUserId(), file);
            return ResponseEntity.ok(uploadedFile);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/task/{taskId}")
    public ResponseEntity<List<FileDTO>> getFilesForTask(@PathVariable Long taskId) {
        return ResponseEntity.ok(fileService.getFilesByTask(taskId));
    }

    @GetMapping("/project/{projectId}")
    public ResponseEntity<List<FileDTO>> getFilesForProject(@PathVariable Long projectId) {
        return ResponseEntity.ok(fileService.getFilesByProject(projectId));
    }

    @GetMapping
    public ResponseEntity<List<FileDTO>> getMyFiles() {
        return ResponseEntity.ok(fileService.getFilesByUser(getCurrentUserId()));
    }

    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal())) {
            String username = authentication.getName();
            return userRepository.findByUsername(username)
                    .map(User::getIdUser)
                    .orElse(1L); // Fallback
        }
        return 1L; // Fallback for development
    }
}
