package com.groupprojet.service;

import com.groupprojet.dto.AnnouncementDTO;
import com.groupprojet.entity.Announcement;
import com.groupprojet.repository.AnnouncementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnnouncementService {

    private final AnnouncementRepository announcementRepository;

    public List<AnnouncementDTO> getAllAnnouncements() {
        return announcementRepository.findAll()
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<AnnouncementDTO> getAnnouncementsByProject(Long projectId) {
        return announcementRepository.findByProjectIdProject(projectId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<AnnouncementDTO> getAnnouncementsByUser(Long userId) {
        return announcementRepository.findByCreatedByIdUser(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public Optional<AnnouncementDTO> getAnnouncementById(Long id) {
        return announcementRepository.findById(id).map(this::mapToDTO);
    }

    @Transactional
    public AnnouncementDTO createAnnouncement(Announcement announcement) {
        return mapToDTO(announcementRepository.save(announcement));
    }

    @Transactional
    public void deleteAnnouncement(Long id) {
        announcementRepository.deleteById(id);
    }

    private AnnouncementDTO mapToDTO(Announcement a) {
        AnnouncementDTO dto = new AnnouncementDTO();
        dto.setIdAnnouncement(a.getIdAnnouncement());
        if (a.getProject() != null) {
            dto.setProjectId(a.getProject().getIdProject());
            dto.setProjectName(a.getProject().getProjectName());
        }
        dto.setTitle(a.getTitle());
        dto.setContent(a.getContent());
        dto.setType(a.getPriority()); // map priority to type
        dto.setIsPinned(a.getIsPinned());
        dto.setPublishDate(a.getCreatedAt()); // Map createdAt to publishDate
        dto.setExpiryDate(a.getExpiresAt()); // Map expiresAt to expiryDate
        if (a.getCreatedBy() != null) {
            dto.setCreatedById(a.getCreatedBy().getIdUser());
            dto.setCreatedBy(a.getCreatedBy().getFirstName() != null ? a.getCreatedBy().getFirstName()
                    : a.getCreatedBy().getUsername());
        }
        return dto;
    }
}
