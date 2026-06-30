package com.groupprojet.controller;

import com.groupprojet.entity.Comment;
import com.groupprojet.service.CommentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/comments")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CommentController {

    private final CommentService commentService;

    @PostMapping("/task/{taskId}")
    public ResponseEntity<Comment> addComment(@PathVariable Long taskId, @RequestBody Map<String, String> payload) {
        Long currentUserId = 1L; // Normally extracted from JWT Context
        String text = payload.get("text");
        return ResponseEntity.ok(commentService.addCommentToTask(taskId, currentUserId, text));
    }

    @GetMapping("/task/{taskId}")
    public ResponseEntity<List<Comment>> getComments(@PathVariable Long taskId) {
        return ResponseEntity.ok(commentService.getCommentsByTask(taskId));
    }
}
