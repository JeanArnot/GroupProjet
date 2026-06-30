package com.groupprojet.controller;

import com.groupprojet.entity.User;
import com.groupprojet.service.SmartFeatureService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/smart")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SmartFeatureController {

    private final SmartFeatureService smartFeatureService;

    @GetMapping("/project/{projectId}/health")
    public ResponseEntity<Map<String, String>> getProjectHealth(@PathVariable Long projectId) {
        Map<String, String> response = new HashMap<>();
        response.put("healthStatus", smartFeatureService.calculateProjectHealthScore(projectId));
        return ResponseEntity.ok(response);
    }

    @GetMapping("/project/{projectId}/suggest-assignee")
    public ResponseEntity<User> suggestAssignee(@PathVariable Long projectId) {
        User suggestedUser = smartFeatureService.suggestUserForTask(projectId);
        if (suggestedUser != null) {
            return ResponseEntity.ok(suggestedUser);
        }
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/project/{projectId}/prediction")
    public ResponseEntity<Map<String, LocalDateTime>> getPrediction(@PathVariable Long projectId) {
        Map<String, LocalDateTime> response = new HashMap<>();
        response.put("predictedCompletionDate", smartFeatureService.predictProjectCompletion(projectId));
        return ResponseEntity.ok(response);
    }
}
