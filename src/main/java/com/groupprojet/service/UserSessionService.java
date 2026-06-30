package com.groupprojet.service;

import com.groupprojet.entity.UserSession;
import com.groupprojet.repository.UserSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserSessionService {

    private final UserSessionRepository userSessionRepository;

    public List<UserSession> getAllUserSessions() {
        return userSessionRepository.findAll();
    }

    public Optional<UserSession> getUserSessionById(Long id) {
        return userSessionRepository.findById(id);
    }

    public Optional<UserSession> getUserSessionByToken(String token) {
        return userSessionRepository.findBySessionToken(token);
    }

    @Transactional
    public UserSession createUserSession(UserSession userSession) {
        return userSessionRepository.save(userSession);
    }

    @Transactional
    public void deleteUserSession(Long id) {
        userSessionRepository.deleteById(id);
    }
}
