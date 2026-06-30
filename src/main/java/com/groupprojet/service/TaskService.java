package com.groupprojet.service;

import com.groupprojet.dto.TaskDTO;
import com.groupprojet.entity.Project;
import com.groupprojet.entity.Task;
import com.groupprojet.entity.User;
import com.groupprojet.repository.ProjectRepository;
import com.groupprojet.repository.TaskRepository;
import com.groupprojet.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;

    public TaskDTO createTask(TaskDTO taskDTO, Long creatorId) {
        Project project = projectRepository.findById(taskDTO.getProjectId())
                .orElseThrow(() -> new RuntimeException("Project not found"));
        User creator = userRepository.findById(creatorId).orElseThrow();

        Task task = new Task();
        task.setProject(project);
        task.setTaskTitle(taskDTO.getTaskTitle());
        task.setDescription(taskDTO.getDescription());
        task.setPriority(taskDTO.getPriority());
        if (taskDTO.getStatus() != null) {
            task.setStatus(taskDTO.getStatus());
        }
        if (taskDTO.getProgress() != null) {
            task.setProgress(taskDTO.getProgress());
        }
        task.setEstimatedTime(taskDTO.getEstimatedTime());
        task.setDeadline(taskDTO.getDeadline());
        task.setCreatedBy(creator);

        if (taskDTO.getAssignedToId() != null) {
            User assignee = userRepository.findById(taskDTO.getAssignedToId()).orElse(null);
            task.setAssignedTo(assignee);
        }

        Task savedTask = taskRepository.save(task);
        return mapToDTO(savedTask);
    }

    public List<TaskDTO> getTasksByProject(Long projectId) {
        return taskRepository.findByProjectIdProject(projectId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<TaskDTO> getTasksByUser(Long userId) {
        return taskRepository.findByAssignedToIdUser(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public TaskDTO getTaskById(Long taskId) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));
        return mapToDTO(task);
    }

    public TaskDTO updateTask(Long taskId, TaskDTO taskDTO) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));

        if (taskDTO.getTaskTitle() != null)
            task.setTaskTitle(taskDTO.getTaskTitle());
        if (taskDTO.getDescription() != null)
            task.setDescription(taskDTO.getDescription());
        if (taskDTO.getPriority() != null)
            task.setPriority(taskDTO.getPriority());
        if (taskDTO.getStatus() != null)
            task.setStatus(taskDTO.getStatus());
        if (taskDTO.getProgress() != null)
            task.setProgress(taskDTO.getProgress());
        if (taskDTO.getEstimatedTime() != null)
            task.setEstimatedTime(taskDTO.getEstimatedTime());
        if (taskDTO.getDeadline() != null)
            task.setDeadline(taskDTO.getDeadline());

        if (taskDTO.getProjectId() != null) {
            Project project = projectRepository.findById(taskDTO.getProjectId())
                    .orElseThrow(() -> new RuntimeException("Project not found"));
            task.setProject(project);
        }

        if (taskDTO.getAssignedToId() != null) {
            User assignee = userRepository.findById(taskDTO.getAssignedToId()).orElse(null);
            task.setAssignedTo(assignee);
        }

        syncCompletionFields(task);

        Task savedTask = taskRepository.save(task);
        return mapToDTO(savedTask);
    }

    @Transactional
    public void deleteTask(Long taskId) {
        if (!taskRepository.existsById(taskId)) {
            throw new RuntimeException("Task not found");
        }
        taskRepository.deleteById(taskId);
    }

    private void syncCompletionFields(Task task) {
        if ("COMPLETED".equals(task.getStatus()) || "DONE".equals(task.getStatus())) {
            task.setProgress(BigDecimal.valueOf(100));
            if (task.getCompletedAt() == null) {
                task.setCompletedAt(LocalDateTime.now());
            }
        } else {
            task.setCompletedAt(null);
        }
    }

    private TaskDTO mapToDTO(Task task) {
        TaskDTO dto = new TaskDTO();
        dto.setIdTask(task.getIdTask());
        if (task.getProject() != null) {
            dto.setProjectId(task.getProject().getIdProject());
            dto.setProjectName(task.getProject().getProjectName());
        }
        if (task.getAssignedTo() != null) {
            dto.setAssignedToId(task.getAssignedTo().getIdUser());
            dto.setAssigneeName(task.getAssignedTo().getFirstName() + " " + task.getAssignedTo().getLastName());
        }
        dto.setTaskTitle(task.getTaskTitle());
        dto.setDescription(task.getDescription());
        dto.setTaskCode(task.getTaskCode());
        dto.setPriority(task.getPriority());
        dto.setStatus(task.getStatus());
        dto.setProgress(task.getProgress());
        dto.setEstimatedTime(task.getEstimatedTime());
        dto.setDeadline(task.getDeadline());
        return dto;
    }
}
