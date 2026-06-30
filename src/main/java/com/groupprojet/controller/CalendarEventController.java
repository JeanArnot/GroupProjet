package com.groupprojet.controller;

import com.groupprojet.dto.CalendarEventDTO;
import com.groupprojet.entity.CalendarEvent;
import com.groupprojet.entity.User;
import com.groupprojet.repository.UserRepository;
import com.groupprojet.service.CalendarEventService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CalendarEventController {

    private final CalendarEventService calendarEventService;
    private final UserRepository userRepository;

    @GetMapping
    public ResponseEntity<List<CalendarEventDTO>> getMyEvents() {
        List<CalendarEventDTO> events = calendarEventService.getCalendarEventsByUser(getCurrentUserId())
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
        return ResponseEntity.ok(events);
    }

    @PostMapping
    public ResponseEntity<CalendarEventDTO> createEvent(@RequestBody CalendarEventDTO dto) {
        User user = userRepository.findById(getCurrentUserId()).orElseThrow();
        CalendarEvent event = new CalendarEvent();
        event.setUser(user);
        event.setCreatedBy(user);
        event.setTitle(dto.getTitle());
        event.setDescription(dto.getDescription());
        event.setEventType(dto.getEventType() != null ? dto.getEventType() : "PERSONAL");
        event.setColor(dto.getColor());
        event.setStartDatetime(dto.getStartDatetime());
        event.setEndDatetime(dto.getEndDatetime());
        event.setAllDay(dto.getAllDay() != null ? dto.getAllDay() : false);
        event.setLocation(dto.getLocation());

        CalendarEvent saved = calendarEventService.createCalendarEvent(event);
        return ResponseEntity.ok(mapToDTO(saved));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEvent(@PathVariable Long id) {
        calendarEventService.deleteCalendarEvent(id);
        return ResponseEntity.ok().build();
    }

    private CalendarEventDTO mapToDTO(CalendarEvent event) {
        CalendarEventDTO dto = new CalendarEventDTO();
        dto.setIdEvent(event.getIdEvent());
        dto.setTitle(event.getTitle());
        dto.setDescription(event.getDescription());
        dto.setEventType(event.getEventType());
        dto.setColor(event.getColor());
        dto.setStartDatetime(event.getStartDatetime());
        dto.setEndDatetime(event.getEndDatetime());
        dto.setAllDay(event.getAllDay());
        dto.setLocation(event.getLocation());
        return dto;
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
