package com.groupprojet.service;

import com.groupprojet.entity.UserStat;
import com.groupprojet.repository.UserStatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserStatService {

    private final UserStatRepository userStatRepository;

    public List<UserStat> getAllUserStats() {
        return userStatRepository.findAll();
    }

    public Optional<UserStat> getUserStatByUserId(Long userId) {
        return userStatRepository.findByUserIdUser(userId);
    }

    @Transactional
    public UserStat createUserStat(UserStat userStat) {
        return userStatRepository.save(userStat);
    }
}
