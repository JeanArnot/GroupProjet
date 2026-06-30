package com.groupprojet.service;

import com.groupprojet.entity.Project;
import com.groupprojet.entity.Task;
import com.groupprojet.entity.User;
import com.groupprojet.repository.ProjectRepository;
import com.groupprojet.repository.TaskRepository;
import com.groupprojet.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SmartFeatureService {

    private final TaskRepository taskRepository;
    private final UserRepository userRepository;
    private final ProjectRepository projectRepository;

    // 1. Smart Task Assignment (Suggests the best user for a task based on load)
    public User suggestUserForTask(Long projectId) {
        // Simple logic: Find the user in the project with the least active tasks
        List<Task> activeTasks = taskRepository.findByProjectIdProject(projectId)
                .stream()
                .filter(t -> !"COMPLETED".equals(t.getStatus()) && t.getAssignedTo() != null)
                .collect(Collectors.toList());

        Map<User, Long> userLoad = activeTasks.stream()
                .collect(Collectors.groupingBy(Task::getAssignedTo, Collectors.counting()));

        return userLoad.entrySet().stream()
                .min(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null); // Returns null if no data to suggest
    }

    // 2. Real-Time Project Health Score
    public String calculateProjectHealthScore(Long projectId) {
        List<Task> tasks = taskRepository.findByProjectIdProject(projectId);
        if (tasks.isEmpty()) return "HEALTHY";

        long lateTasks = tasks.stream()
                .filter(t -> !"COMPLETED".equals(t.getStatus()) && 
                             t.getDeadline() != null && 
                             t.getDeadline().isBefore(LocalDateTime.now()))
                .count();

        double latePercentage = (double) lateTasks / tasks.size() * 100;

        if (latePercentage > 30) {
            return "CRITICAL";
        } else if (latePercentage > 10) {
            return "RISK";
        }
        return "HEALTHY";
    }

    // 3. Smart Deadline Prediction (Simple heuristic)
    public LocalDateTime predictProjectCompletion(Long projectId) {
        List<Task> tasks = taskRepository.findByProjectIdProject(projectId);
        long pendingTasks = tasks.stream().filter(t -> !"COMPLETED".equals(t.getStatus())).count();
        
        // Assume team can do 2 tasks a day on average
        long daysNeeded = (pendingTasks / 2) + 1;
        
        return LocalDateTime.now().plusDays(daysNeeded);
    }
}
