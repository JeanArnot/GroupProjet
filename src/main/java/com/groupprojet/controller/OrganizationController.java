package com.groupprojet.controller;

import com.groupprojet.entity.Organization;
import com.groupprojet.service.OrganizationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/Organizations")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class OrganizationController {
    private final OrganizationService OrganizationService;

    @GetMapping
    public ResponseEntity<List<Organization>> getAllOrganizations() {
        return ResponseEntity.ok(OrganizationService.getAllOrganizations());
    }

    @PostMapping
    public ResponseEntity<Organization> createOrganization(@RequestBody Organization Organization) {
        return ResponseEntity.ok(OrganizationService.createOrganization(Organization));
    }
}
