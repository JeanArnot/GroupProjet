package com.groupprojet.controller;

import com.groupprojet.entity.Supervisor;
import com.groupprojet.service.SupervisorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/supervisors")
@RequiredArgsConstructor
public class SupervisorController {

    private final SupervisorService supervisorService;

    @GetMapping
    public ResponseEntity<List<Supervisor>> getAllSupervisors() {
        return ResponseEntity.ok(supervisorService.getAllSupervisors());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Supervisor> getSupervisorById(@PathVariable Long id) {
        return supervisorService.getSupervisorById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Supervisor> createSupervisor(@RequestBody Supervisor supervisor) {
        return ResponseEntity.ok(supervisorService.createSupervisor(supervisor));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSupervisor(@PathVariable Long id) {
        supervisorService.deleteSupervisor(id);
        return ResponseEntity.noContent().build();
    }
}
