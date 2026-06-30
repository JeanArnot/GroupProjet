package com.groupprojet.service;

import com.groupprojet.entity.Task;
import com.groupprojet.entity.TaskDependency;
import com.groupprojet.repository.TaskDependencyRepository;
import com.groupprojet.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskDependencyService {

    private final TaskDependencyRepository dependencyRepository;
    private final TaskRepository taskRepository;

    public void addDependency(Long taskId, Long dependsOnTaskId) {
        Task task = taskRepository.findById(taskId).orElseThrow();
        Task dependsOn = taskRepository.findById(dependsOnTaskId).orElseThrow();

        TaskDependency dependency = new TaskDependency();
        dependency.setTask(task);
        dependency.setDependsOnTask(dependsOn);

        dependencyRepository.save(dependency);
    }

    public boolean canStartTask(Long taskId) {
        List<TaskDependency> dependencies = dependencyRepository.findByTaskIdTask(taskId);
        
        for (TaskDependency dep : dependencies) {
            if (!"COMPLETED".equals(dep.getDependsOnTask().getStatus())) {
                return false; // Cannot start if any dependency is not completed
            }
        }
        return true;
    }
}
