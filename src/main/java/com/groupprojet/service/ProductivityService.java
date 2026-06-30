package com.groupprojet.service;

import com.groupprojet.entity.Task;
import com.groupprojet.entity.User;
import com.groupprojet.entity.UserProductivity;
import com.groupprojet.repository.TaskRepository;
import com.groupprojet.repository.UserProductivityRepository;
import com.groupprojet.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductivityService {

    private final TaskRepository taskRepository;
    private final UserProductivityRepository userProductivityRepository;
    private final UserRepository userRepository;

    public UserProductivity updateProductivityScore(Long userId) {
        User user = userRepository.findById(userId).orElseThrow();
        List<Task> userTasks = taskRepository.findByAssignedToIdUser(userId);

        long completed = userTasks.stream().filter(t -> "COMPLETED".equals(t.getStatus())).count();
        long late = userTasks.stream()
                .filter(t -> t.getDeadline() != null && t.getDeadline().isBefore(LocalDateTime.now()) && !"COMPLETED".equals(t.getStatus()))
                .count();

        UserProductivity prod = userProductivityRepository.findByUserIdUser(userId)
                .orElse(new UserProductivity());
        
        prod.setUser(user);
        prod.setCompletedTasks((int) completed);
        prod.setLateTasks((int) late);
        
        // Simple Gamification Score: Completed tasks * 10 - Late tasks * 5
        double score = Math.max(0, (completed * 10.0) - (late * 5.0));
        prod.setProductivityScore(BigDecimal.valueOf(score).setScale(2, RoundingMode.HALF_UP));

        return userProductivityRepository.save(prod);
    }
}
