package com.groupprojet.service;

import com.groupprojet.dto.MeetingDTO;
import com.groupprojet.entity.Meeting;
import com.groupprojet.entity.Project;
import com.groupprojet.entity.User;
import com.groupprojet.repository.MeetingRepository;
import com.groupprojet.repository.ProjectRepository;
import com.groupprojet.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MeetingService {

    private final MeetingRepository meetingRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    public MeetingDTO scheduleMeeting(Long projectId, Long creatorId, String title, String description,
            LocalDateTime date, int duration) {
        Project project = projectRepository.findById(projectId).orElseThrow();
        User creator = userRepository.findById(creatorId).orElseThrow();

        Meeting meeting = new Meeting();
        meeting.setProject(project);
        meeting.setCreatedBy(creator);
        meeting.setTitle(title);
        meeting.setDescription(description);
        meeting.setMeetingDate(date);
        meeting.setDurationMinutes(duration);

        // Auto-generate a dummy link for now (could integrate Zoom/Google Meet APIs
        // later)
        meeting.setMeetingLink(
                "https://meet.groupprojet.com/" + java.util.UUID.randomUUID().toString().substring(0, 8));

        Meeting saved = meetingRepository.save(meeting);

        // Notify project owner or members (simplified: notify creator as example)
        notificationService.createAndSendNotification(
                creator,
                "Réunion programmée",
                "Vous avez planifié: " + title + " pour le projet " + project.getProjectName(),
                "MEETING");

        return mapToDTO(saved);
    }

    public List<MeetingDTO> getMeetingsByProject(Long projectId) {
        return meetingRepository.findByProjectIdProject(projectId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<MeetingDTO> getMeetingsByUser(Long userId) {
        return meetingRepository.findByCreatedByIdUser(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public MeetingDTO getMeetingById(Long id) {
        return meetingRepository.findById(id)
                .map(this::mapToDTO)
                .orElseThrow(() -> new RuntimeException("Meeting not found"));
    }

    @Transactional
    public MeetingDTO updateMeeting(Long id, MeetingDTO dto) {
        Meeting meeting = meetingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Meeting not found"));

        if (dto.getProjectId() != null) {
            Project project = projectRepository.findById(dto.getProjectId())
                    .orElseThrow(() -> new RuntimeException("Project not found"));
            meeting.setProject(project);
        }
        if (dto.getTitle() != null)
            meeting.setTitle(dto.getTitle());
        if (dto.getDescription() != null)
            meeting.setDescription(dto.getDescription());
        if (dto.getMeetingDate() != null)
            meeting.setMeetingDate(dto.getMeetingDate());
        if (dto.getDurationMinutes() != null)
            meeting.setDurationMinutes(dto.getDurationMinutes());
        if (dto.getMeetingLink() != null)
            meeting.setMeetingLink(dto.getMeetingLink());

        return mapToDTO(meetingRepository.save(meeting));
    }

    @Transactional
    public void deleteMeeting(Long id) {
        if (!meetingRepository.existsById(id)) {
            throw new RuntimeException("Meeting not found");
        }
        meetingRepository.deleteById(id);
    }

    private MeetingDTO mapToDTO(Meeting m) {
        MeetingDTO dto = new MeetingDTO();
        dto.setIdMeeting(m.getIdMeeting());
        if (m.getProject() != null)
            dto.setProjectId(m.getProject().getIdProject());
        dto.setTitle(m.getTitle());
        dto.setDescription(m.getDescription());
        dto.setMeetingDate(m.getMeetingDate());
        dto.setDurationMinutes(m.getDurationMinutes());
        dto.setMeetingLink(m.getMeetingLink());

        // Fallbacks for properties not currently in DB
        dto.setLocation(m.getMeetingLink() != null ? "En ligne" : "À définir");

        if (m.getMeetingDate() != null) {
            dto.setStatus(m.getMeetingDate().isBefore(LocalDateTime.now()) ? "COMPLETED" : "PLANNED");
        } else {
            dto.setStatus("PLANNED");
        }

        dto.setType("TEAM");

        return dto;
    }
}
