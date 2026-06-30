package com.groupprojet.service;

import com.groupprojet.entity.CalendarEvent;
import com.groupprojet.repository.CalendarEventRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CalendarEventService {

    private final CalendarEventRepository calendarEventRepository;

    public List<CalendarEvent> getAllCalendarEvents() {
        return calendarEventRepository.findAll();
    }

    public List<CalendarEvent> getCalendarEventsByUser(Long userId) {
        return calendarEventRepository.findByUserIdUser(userId);
    }

    public Optional<CalendarEvent> getCalendarEventById(Long id) {
        return calendarEventRepository.findById(id);
    }

    @Transactional
    public CalendarEvent createCalendarEvent(CalendarEvent calendarEvent) {
        return calendarEventRepository.save(calendarEvent);
    }

    @Transactional
    public void deleteCalendarEvent(Long id) {
        calendarEventRepository.deleteById(id);
    }
}
