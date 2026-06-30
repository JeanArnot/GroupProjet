package com.groupprojet.service;

import com.groupprojet.dto.ProjectDTO;
import com.groupprojet.entity.Organization;
import com.groupprojet.entity.Project;
import com.groupprojet.entity.User;
import com.groupprojet.repository.OrganizationRepository;
import com.groupprojet.repository.ProjectRepository;
import com.groupprojet.repository.UserRepository;
import com.groupprojet.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProjectService {

    private final ProjectRepository projectRepository;
    private final OrganizationRepository OrganizationRepository;
    private final UserRepository userRepository;
    private final TaskRepository taskRepository;

    @Transactional
    public void updateProjectProgressAndHealth(Long projectId) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new RuntimeException("Project not found"));

        long totalTasks = taskRepository.countByProjectIdProject(projectId);
        long completedTasks = taskRepository.countByProjectIdProjectAndStatus(projectId, "DONE")
                + taskRepository.countByProjectIdProjectAndStatus(projectId, "COMPLETED");

        project.setTotalTasks((int) totalTasks);
        project.setCompletedTasks((int) completedTasks);

        if (totalTasks > 0) {
            double progress = ((double) completedTasks / totalTasks) * 100.0;
            project.setProgress(java.math.BigDecimal.valueOf(progress).setScale(2, java.math.RoundingMode.HALF_UP));
        } else {
            project.setProgress(java.math.BigDecimal.ZERO);
        }

        // Health Score Logic
        long overdueTasks = taskRepository.countByProjectIdProjectAndStatus(projectId, "OVERDUE");
        if (overdueTasks > 3 || (project.getEndDate() != null && project.getEndDate().isBefore(LocalDate.now())
                && project.getProgress().doubleValue() < 100)) {
            project.setHealthStatus("CRITICAL");
        } else if (overdueTasks > 0) {
            project.setHealthStatus("WARNING");
        } else {
            project.setHealthStatus("GOOD");
        }

        if (project.getProgress().doubleValue() == 100.0) {
            project.setStatus("COMPLETED");
        }

        projectRepository.save(project);
    }

    public ProjectDTO createProject(ProjectDTO projectDTO, Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Organization Organization = null;
        if (projectDTO.getOrganizationId() != null) {
            Organization = OrganizationRepository.findById(projectDTO.getOrganizationId())
                    .orElseThrow(() -> new RuntimeException("Organization not found"));
        }

        Project project = new Project();
        project.setProjectName(projectDTO.getProjectName());
        project.setDescription(projectDTO.getDescription());
        project.setProjectCode(projectDTO.getProjectCode());
        project.setOrganization(Organization);
        project.setCreatedBy(user);
        project.setStartDate(projectDTO.getStartDate());
        project.setEndDate(projectDTO.getEndDate());

        Project savedProject = projectRepository.save(project);
        return mapToDTO(savedProject);
    }

    @Transactional
    public ProjectDTO updateProject(Long projectId, ProjectDTO projectDTO) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new RuntimeException("Project not found"));

        if (projectDTO.getProjectName() != null)
            project.setProjectName(projectDTO.getProjectName());
        if (projectDTO.getDescription() != null)
            project.setDescription(projectDTO.getDescription());
        if (projectDTO.getProjectCode() != null)
            project.setProjectCode(projectDTO.getProjectCode());
        if (projectDTO.getStatus() != null)
            project.setStatus(projectDTO.getStatus());
        if (projectDTO.getPriority() != null)
            project.setPriority(projectDTO.getPriority());
        if (projectDTO.getStartDate() != null)
            project.setStartDate(projectDTO.getStartDate());
        if (projectDTO.getEndDate() != null)
            project.setEndDate(projectDTO.getEndDate());
        if (projectDTO.getProgress() != null)
            project.setProgress(projectDTO.getProgress());

        if (projectDTO.getOrganizationId() != null) {
            Organization Organization = OrganizationRepository.findById(projectDTO.getOrganizationId())
                    .orElseThrow(() -> new RuntimeException("Organization not found"));
            project.setOrganization(Organization);
        }

        return mapToDTO(projectRepository.save(project));
    }

    @Transactional
    public ProjectDTO archiveProject(Long projectId) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new RuntimeException("Project not found"));
        project.setArchived(true);
        project.setStatus("ARCHIVED");
        return mapToDTO(projectRepository.save(project));
    }

    @Transactional
    public void deleteProject(Long projectId) {
        if (!projectRepository.existsById(projectId)) {
            throw new RuntimeException("Project not found");
        }
        projectRepository.deleteById(projectId);
    }

    public List<ProjectDTO> getProjectsByOrganization(Long OrganizationId) {
        return projectRepository.findByOrganizationIdOrganization(OrganizationId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<ProjectDTO> getProjectsByUser(Long userId) {
        // Return projects created by this user
        // OR projects where the user is a member, depending on the data model.
        // For now, let's use created_by as the basic link.
        return projectRepository.findByCreatedByIdUser(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public ProjectDTO getProjectById(Long projectId) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new RuntimeException("Project not found"));
        return mapToDTO(project);
    }

    private ProjectDTO mapToDTO(Project project) {
        ProjectDTO dto = new ProjectDTO();
        dto.setIdProject(project.getIdProject());
        if (project.getOrganization() != null)
            dto.setOrganizationId(project.getOrganization().getIdOrganization());
        dto.setProjectName(project.getProjectName());
        dto.setDescription(project.getDescription());
        dto.setProjectCode(project.getProjectCode());
        dto.setStatus(project.getStatus());
        dto.setPriority(project.getPriority());
        if (project.getProgress() != null) {
            dto.setProgress(project.getProgress());
        } else {
            dto.setProgress(java.math.BigDecimal.ZERO);
        }
        dto.setHealthStatus(project.getHealthStatus());
        dto.setStartDate(project.getStartDate());
        dto.setEndDate(project.getEndDate());
        return dto;
    }
}
