package com.groupprojet.service;

import com.groupprojet.dto.MilestoneDTO;
import com.groupprojet.entity.Milestone;
import com.groupprojet.entity.Project;
import com.groupprojet.repository.MilestoneRepository;
import com.groupprojet.repository.ProjectRepository;
import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MilestoneService {
    private final MilestoneRepository milestoneRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;

    public MilestoneDTO createMilestone(MilestoneDTO dto, Long userId) {
        Project project = projectRepository.findById(dto.getProjectId())
                .orElseThrow(() -> new RuntimeException("Project not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Milestone milestone = new Milestone();
        milestone.setProject(project);
        milestone.setMilestoneName(dto.getMilestoneName());
        milestone.setDescription(dto.getDescription());
        milestone.setDueDate(dto.getDueDate());
        milestone.setCreatedBy(user);

        Milestone saved = milestoneRepository.save(milestone);
        dto.setIdMilestone(saved.getIdMilestone());
        return dto;
    }

    public List<MilestoneDTO> getMilestonesByProject(Long projectId) {
        return milestoneRepository.findByProjectIdProject(projectId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<MilestoneDTO> getMilestonesByUser(Long userId) {
        List<Project> userProjects = projectRepository.findByCreatedByIdUser(userId);
        List<MilestoneDTO> userMilestones = new ArrayList<>();

        for (Project p : userProjects) {
            userMilestones.addAll(getMilestonesByProject(p.getIdProject()));
        }

        return userMilestones;
    }

    public MilestoneDTO getMilestoneById(Long id) {
        return milestoneRepository.findById(id)
                .map(this::mapToDTO)
                .orElseThrow(() -> new RuntimeException("Milestone not found"));
    }

    @Transactional
    public MilestoneDTO updateMilestone(Long id, MilestoneDTO dto) {
        Milestone milestone = milestoneRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Milestone not found"));

        if (dto.getProjectId() != null) {
            Project project = projectRepository.findById(dto.getProjectId())
                    .orElseThrow(() -> new RuntimeException("Project not found"));
            milestone.setProject(project);
        }
        if (dto.getMilestoneName() != null)
            milestone.setMilestoneName(dto.getMilestoneName());
        if (dto.getDescription() != null)
            milestone.setDescription(dto.getDescription());
        if (dto.getDueDate() != null)
            milestone.setDueDate(dto.getDueDate());
        if (dto.getStatus() != null)
            milestone.setStatus(dto.getStatus());
        if (dto.getCompletionPercentage() != null)
            milestone.setCompletionPercentage(dto.getCompletionPercentage());

        return mapToDTO(milestoneRepository.save(milestone));
    }

    @Transactional
    public void deleteMilestone(Long id) {
        if (!milestoneRepository.existsById(id)) {
            throw new RuntimeException("Milestone not found");
        }
        milestoneRepository.deleteById(id);
    }

    private MilestoneDTO mapToDTO(Milestone m) {
        MilestoneDTO dto = new MilestoneDTO();
        dto.setIdMilestone(m.getIdMilestone());
        dto.setProjectId(m.getProject().getIdProject());
        dto.setMilestoneName(m.getMilestoneName());
        dto.setDescription(m.getDescription());
        dto.setDueDate(m.getDueDate());
        dto.setStatus(m.getStatus());
        dto.setCompletionPercentage(m.getCompletionPercentage());
        return dto;
    }
}
