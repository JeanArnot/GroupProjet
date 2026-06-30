package com.groupprojet.service;

import com.groupprojet.entity.Comment;
import com.groupprojet.entity.Task;
import com.groupprojet.entity.User;
import com.groupprojet.repository.CommentRepository;
import com.groupprojet.repository.TaskRepository;
import com.groupprojet.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CommentService {

    private final CommentRepository commentRepository;
    private final TaskRepository taskRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    public Comment addCommentToTask(Long taskId, Long userId, String text) {
        Task task = taskRepository.findById(taskId).orElseThrow();
        User user = userRepository.findById(userId).orElseThrow();

        Comment comment = new Comment();
        comment.setTask(task);
        comment.setUser(user);
        comment.setCommentText(text);

        Comment saved = commentRepository.save(comment);

        // Update task comment count
        task.setCommentCount(task.getCommentCount() + 1);
        taskRepository.save(task);

        // Smart Logic: Notify assigned user if someone else comments
        if (task.getAssignedTo() != null && !task.getAssignedTo().getIdUser().equals(userId)) {
            notificationService.createAndSendNotification(
                    task.getAssignedTo(),
                    "Nouveau commentaire",
                    user.getFirstName() + " a commenté votre tâche: " + task.getTaskTitle(),
                    "COMMENT"
            );
        }

        return saved;
    }

    public List<Comment> getCommentsByTask(Long taskId) {
        return commentRepository.findByTaskIdTask(taskId);
    }
}
