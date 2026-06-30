package com.groupprojet.service;

import com.groupprojet.dto.SubmissionDTO;
import com.groupprojet.entity.Project;
import com.groupprojet.entity.Submission;
import com.groupprojet.entity.User;
import com.groupprojet.repository.ProjectRepository;
import com.groupprojet.repository.SubmissionRepository;
import com.groupprojet.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SubmissionService {

    private final SubmissionRepository submissionRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;

    public List<SubmissionDTO> getAllSubmissions() {
        return submissionRepository.findAll()
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<SubmissionDTO> getSubmissionsByProject(Long projectId) {
        return submissionRepository.findByProjectIdProject(projectId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<SubmissionDTO> getSubmissionsByUser(Long userId) {
        return submissionRepository.findBySubmittedByIdUser(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public Optional<SubmissionDTO> getSubmissionById(Long id) {
        return submissionRepository.findById(id).map(this::mapToDTO);
    }

    @Transactional
    public SubmissionDTO createSubmission(SubmissionDTO dto, Long userId) {
        Project project = null;
        if (dto.getProjectId() != null) {
            project = projectRepository.findById(dto.getProjectId()).orElse(null);
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Submission submission = new Submission();
        submission.setProject(project);
        submission.setSubmittedBy(user);
        submission.setSubmissionTitle(dto.getSubmissionTitle());
        submission.setSubmissionNote(dto.getSubmissionNote());

        return mapToDTO(submissionRepository.save(submission));
    }

    @Transactional
    public SubmissionDTO updateSubmission(Long id, SubmissionDTO dto, Long userId) {
        Submission submission = submissionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Submission not found"));

        if (dto.getSubmissionTitle() != null) {
            submission.setSubmissionTitle(dto.getSubmissionTitle());
        }
        if (dto.getSubmissionNote() != null) {
            submission.setSubmissionNote(dto.getSubmissionNote());
        }
        if (dto.getFileUrls() != null) {
            submission.setFileUrls(dto.getFileUrls());
        }
        if (dto.getProjectId() != null) {
            Project project = projectRepository.findById(dto.getProjectId()).orElse(null);
            submission.setProject(project);
        }

        return mapToDTO(submissionRepository.save(submission));
    }

    @Transactional
    public void deleteSubmission(Long id) {
        submissionRepository.deleteById(id);
    }

    private SubmissionDTO mapToDTO(Submission s) {
        SubmissionDTO dto = new SubmissionDTO();
        dto.setIdSubmission(s.getIdSubmission());
        if (s.getProject() != null) {
            dto.setProjectId(s.getProject().getIdProject());
            dto.setProjectName(s.getProject().getProjectName());
        }
        if (s.getTask() != null)
            dto.setTaskId(s.getTask().getIdTask());
        if (s.getMilestone() != null)
            dto.setMilestoneId(s.getMilestone().getIdMilestone());
        if (s.getSubmittedBy() != null) {
            dto.setSubmittedById(s.getSubmittedBy().getIdUser());
            dto.setSubmittedBy(s.getSubmittedBy().getFirstName() != null ? s.getSubmittedBy().getFirstName()
                    : s.getSubmittedBy().getUsername());
        }
        dto.setSubmissionTitle(s.getSubmissionTitle());
        dto.setSubmissionNote(s.getSubmissionNote());
        dto.setFileUrls(s.getFileUrls());
        dto.setStatus(s.getStatus());
        dto.setGrade(s.getGrade());
        dto.setFeedback(s.getFeedback());
        dto.setEvaluatedAt(s.getEvaluatedAt());
        dto.setDueDate(s.getDueDate());
        dto.setSubmittedAt(s.getSubmittedAt());
        dto.setIsLate(s.getIsLate());
        dto.setLateDurationHours(s.getLateDurationHours());
        return dto;
    }
}
